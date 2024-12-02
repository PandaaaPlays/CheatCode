package ca.usherbrooke.intellijudessqlformatter

import com.intellij.openapi.actionSystem.AnAction
import com.intellij.openapi.actionSystem.AnActionEvent
import com.intellij.openapi.actionSystem.CommonDataKeys
import com.intellij.openapi.actionSystem.Presentation
import com.intellij.openapi.command.WriteCommandAction
import com.intellij.openapi.editor.Editor
import com.intellij.openapi.editor.SelectionModel
import com.intellij.openapi.project.Project
import com.intellij.openapi.ui.Messages
import java.io.File
import java.io.InputStream
import java.nio.file.Files

class FormatSQL : AnAction() {

    override fun actionPerformed(e: AnActionEvent) {
        val project: Project? = e.project
        if (project == null) {
            Messages.showMessageDialog("No project context available!", "Error", Messages.getErrorIcon())
            return
        }

        val editor: Editor? = e.getData(CommonDataKeys.EDITOR)
        if (editor == null) {
            Messages.showMessageDialog("No active editor found!", "Error", Messages.getErrorIcon())
            return
        }

        val document = editor.document
        val selectionModel: SelectionModel = editor.selectionModel
        val inputSql = selectionModel.selectedText ?: document.text

        val isInline = templateText?.contains("Inline")

        try {
            // Load the PowerShell script from resources
            val scriptStream: InputStream? =
                javaClass.classLoader.getResourceAsStream("powershell/Format-MariaDB-SQL.ps1")
            if (scriptStream == null) {
                Messages.showErrorDialog("Failed to locate PowerShell script in plugin resources.", "Error")
                return
            }

            // Write the script to a temporary file
            val scriptFile = File.createTempFile("Format-MariaDB-SQL", ".ps1")
            scriptStream.use { input ->
                Files.copy(input, scriptFile.toPath(), java.nio.file.StandardCopyOption.REPLACE_EXISTING)
            }

            // Create a temporary SQL file for the input (UTF8-Bom)
            val tempFile = File.createTempFile("temp_sql_script", ".sql")
            tempFile.writeText("\uFEFF" + inputSql, Charsets.UTF_8)

            // Prepare the PowerShell command
            val command = mutableListOf(
                "powershell.exe",
                "-ExecutionPolicy", "Bypass",
                "-File", scriptFile.absolutePath,
                "-inputFile", tempFile.absolutePath
            )
            if (isInline == true) {
                command.add("-inline")
            }

            val processBuilder = ProcessBuilder(command)
            processBuilder.redirectErrorStream(true)
            val process = processBuilder.start()

            // Capture output
            val output = process.inputStream.bufferedReader().readText()
            process.waitFor()

            // Delete temporary files
            tempFile.delete()
            scriptFile.delete()

            // Normalize line endings
            val normalizedOutput = output.replace("\r\n", "\n").replace("\r", "\n")

            // Update the document
            WriteCommandAction.runWriteCommandAction(project) {
                if (selectionModel.hasSelection()) {
                    document.replaceString(
                        selectionModel.selectionStart,
                        selectionModel.selectionEnd,
                        normalizedOutput
                    )
                } else {
                    document.setText(normalizedOutput)
                }
            }

        } catch (ex: Exception) {
            Messages.showErrorDialog("Failed to execute PowerShell script: ${ex.message}", "Error")
        }
    }
}
