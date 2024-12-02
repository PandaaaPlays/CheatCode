"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.activate = activate;
// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
const node_child_process_1 = require("node:child_process");
const vscode = __importStar(require("vscode"));
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
const os = __importStar(require("os"));
//import { SQLFormat } from './SQLFormat';
// This method is called when your extension is activated
// Your extension is activated the very first time the command is executed
function activate(context) {
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
            (0, node_child_process_1.exec)(command, (error, stdout, stderr) => {
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
                    }
                    else {
                        // Replace the whole document
                        const fullRange = new vscode.Range(document.positionAt(0), document.positionAt(document.getText().length));
                        editBuilder.replace(fullRange, formattedSql);
                    }
                });
            });
        }
        else {
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
            (0, node_child_process_1.exec)(command, (error, stdout, stderr) => {
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
                    }
                    else {
                        // Replace the whole document
                        const fullRange = new vscode.Range(document.positionAt(0), document.positionAt(document.getText().length));
                        editBuilder.replace(fullRange, formattedSql);
                    }
                });
            });
        }
        else {
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
//# sourceMappingURL=extension.js.map