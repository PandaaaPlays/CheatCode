// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
import { exec } from 'node:child_process';
import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';
import * as os from 'os';
//import { SQLFormat } from './SQLFormat';

// This method is called when your extension is activated
// Your extension is activated the very first time the command is executed
export function activate(context: vscode.ExtensionContext) {

	const disposable = vscode.commands.registerCommand('udes-sqlformatter.mariaDBFormatter', () => {
        // Get the current active text editor
        const editor = vscode.window.activeTextEditor;

        if (editor) {

			let document = editor.document;
			let selection = editor.selection;
			let useSelection = !selection.isEmpty;
    		let inputSql = useSelection ? document.getText(editor.selection) : document.getText();

            const tempFilePath = path.join(os.tmpdir(), 'temp_sql_script.sql');
            // Write the SQL to the temporary file with UTF-8 BOM
            const bom = Buffer.from([0xEF, 0xBB, 0xBF]);
            const sqlBuffer = Buffer.concat([bom, Buffer.from(inputSql, 'utf-8')]);
            fs.writeFileSync(tempFilePath, sqlBuffer);

            const scriptPath = path.join(__dirname, '..', 'powershell', 'Format-MariaDB-SQL.ps1');

			// Construct the command
            const command = `powershell.exe -ExecutionPolicy Bypass -File "${scriptPath}" -inputFile "${tempFilePath}"`;

            exec(command, (error, stdout, stderr) => {
                fs.unlinkSync(tempFilePath);
                if (error) {
                    vscode.window.showErrorMessage(`Error: ${error.message}`);
                    return;
                }
                if (stderr) {
                    vscode.window.showErrorMessage(`stderr: ${stderr}`);
                    return;
                }
				let formattedSql = stdout;

                // Start an edit operation to replace the text in the editor
                editor.edit(editBuilder => {
                    if (useSelection) {
                        editBuilder.replace(selection, formattedSql);
                    } else {
                        // Replace the whole document
                        const fullRange = new vscode.Range(
                            document.positionAt(0),
                            document.positionAt(document.getText().length)
                        );
                        editBuilder.replace(fullRange, formattedSql);
                    }
                });
            });

        } else {
            vscode.window.showInformationMessage('Aucun editeur actif trouvé.');
        }
    });

    const disposableInLine = vscode.commands.registerCommand('udes-sqlformatter.mariaDBFormatterInLine', async () => {
        // Get the current active text editor
        const editor = vscode.window.activeTextEditor;

        if (editor) {
			let document = editor.document;
			let selection = editor.selection;
			let useSelection = !selection.isEmpty;
    		let inputSql = useSelection ? document.getText(editor.selection) : document.getText();

            const tempFilePath = path.join(os.tmpdir(), 'temp_sql_script.sql');
            // Write the SQL to the temporary file with UTF-8 BOM
            const bom = Buffer.from([0xEF, 0xBB, 0xBF]);
            const sqlBuffer = Buffer.concat([bom, Buffer.from(inputSql, 'utf-8')]);
            fs.writeFileSync(tempFilePath, sqlBuffer);

            const scriptPath = path.join(__dirname, '..', 'powershell', 'Format-MariaDB-SQL.ps1');

			// Construct the command
            const command = `powershell.exe -ExecutionPolicy Bypass -File "${scriptPath}" -inputFile "${tempFilePath}" -inLine`;

            exec(command, (error, stdout, stderr) => {
                fs.unlinkSync(tempFilePath);
                if (error) {
                    vscode.window.showErrorMessage(`Error: ${error.message}`);
                    return;
                }
                if (stderr) {
                    vscode.window.showErrorMessage(`stderr: ${stderr}`);
                    return;
                }
				let formattedSql = stdout;

                // Start an edit operation to replace the text in the editor
                editor.edit(editBuilder => {
                    if (useSelection) {
                        editBuilder.replace(selection, formattedSql);
                    } else {
                        // Replace the whole document
                        const fullRange = new vscode.Range(
                            document.positionAt(0),
                            document.positionAt(document.getText().length)
                        );
                        editBuilder.replace(fullRange, formattedSql);
                    }
                });
            });
        } else {
            vscode.window.showInformationMessage('Aucun editeur actif trouvé.');
        }
    });


	// Si jamais on veut le faire directement en JS
	/*let formattedSql = new SQLFormat().format(inputSql);
	// Apply the formatted SQL back to the editor
	editor.edit(editBuilder => {
		if (useSelection) {
			editBuilder.replace(selection, formattedSql);
		} else {
			const fullRange = new vscode.Range(
				document.positionAt(0),
				document.positionAt(document.getText().length)
			);
			editBuilder.replace(fullRange, formattedSql);
		}
	});*/


	context.subscriptions.push(disposable);
	context.subscriptions.push(disposableInLine);
}
