// Le module 'vscode' contient l'API d'extensibilité de VS Code.
// On importe ce module et on le référence avec l'alias vscode ci-dessous.
import { exec } from 'node:child_process';
import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';
import * as os from 'os';

// Cette méthode est appelée lorsque votre extension est activée.
// L'extension est activée la toute première fois qu'une commande est exécutée.
export function activate(context: vscode.ExtensionContext) {

    // Enregistre une commande pour formater du SQL en mode classique.
	const disposable = vscode.commands.registerCommand('udes-sqlformatter.Formatter', () => {
        // Récupère l'éditeur de texte actif.
        const editor = vscode.window.activeTextEditor;

        if (editor) {
            // Récupère le document actuel et le texte sélectionné.
			let document = editor.document;
			let selection = editor.selection;
			let useSelection = !selection.isEmpty; // Utilise la sélection si elle n'est pas vide.
    		let inputSql = useSelection ? document.getText(editor.selection) : document.getText();

            // Crée un fichier temporaire pour stocker le SQL (car il peut etre extra long).
            const tempFilePath = path.join(os.tmpdir(), 'temp_sql_script.sql');

            // Ajoute UTF-8 BOM pour le fichier temporaire.
            const bom = Buffer.from([0xEF, 0xBB, 0xBF]);
            const sqlBuffer = Buffer.concat([bom, Buffer.from(inputSql, 'utf-8')]);
            fs.writeFileSync(tempFilePath, sqlBuffer);

            // Chemin vers le script PowerShell utilisé pour le formatage.
            const scriptPath = path.join(__dirname, '..', 'powershell', 'Exec-Format-SQL.ps1');

			// Commande à exécuter.
            const command = `powershell.exe -ExecutionPolicy Bypass -File "${scriptPath}" -inputFile "${tempFilePath}"`;

            // Exécute la commande PowerShell.
            exec(command, (error, stdout, stderr) => {
                // Supprime le fichier temporaire après utilisation.
                fs.unlinkSync(tempFilePath);

                if (error) {
                    vscode.window.showErrorMessage(`Erreur : ${error.message}`);
                    return;
                }
                if (stderr) {
                    vscode.window.showErrorMessage(`Erreur standard : ${stderr}`);
                    return;
                }

				// Le SQL formaté est contenu dans stdout.
				let formattedSql = stdout;

                // Modifie le document dans l'éditeur pour insérer le SQL formaté.
                editor.edit(editBuilder => {
                    if (useSelection) {
                        editBuilder.replace(selection, formattedSql);
                    } else {
                        // Remplace tout le document si aucune sélection n'est faite.
                        const fullRange = new vscode.Range(
                            document.positionAt(0),
                            document.positionAt(document.getText().length)
                        );
                        editBuilder.replace(fullRange, formattedSql);
                    }
                });
            });

        } else {
            // Aucun éditeur actif trouvé.
            vscode.window.showInformationMessage('Aucun éditeur actif trouvé.');
        }
    });

    // Enregistre une commande pour formater du SQL en mode "inline".
    const disposableInLine = vscode.commands.registerCommand('udes-sqlformatter.FormatterInLine', async () => {
        const editor = vscode.window.activeTextEditor;

        if (editor) {
			let document = editor.document;
			let selection = editor.selection;
			let useSelection = !selection.isEmpty;
    		let inputSql = useSelection ? document.getText(editor.selection) : document.getText();

            const tempFilePath = path.join(os.tmpdir(), 'temp_sql_script.sql');
            const bom = Buffer.from([0xEF, 0xBB, 0xBF]);
            const sqlBuffer = Buffer.concat([bom, Buffer.from(inputSql, 'utf-8')]);
            fs.writeFileSync(tempFilePath, sqlBuffer);

            const scriptPath = path.join(__dirname, '..', 'powershell', 'Exec-Format-SQL.ps1');

			// Commande pour le mode "inline".
            const command = `powershell.exe -ExecutionPolicy Bypass -File "${scriptPath}" -inputFile "${tempFilePath}" -inLine`;

            exec(command, (error, stdout, stderr) => {
                fs.unlinkSync(tempFilePath);

                if (error) {
                    vscode.window.showErrorMessage(`Erreur : ${error.message}`);
                    return;
                }
                if (stderr) {
                    vscode.window.showErrorMessage(`Erreur standard : ${stderr}`);
                    return;
                }
				let formattedSql = stdout;

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
                });
            });
        } else {
            vscode.window.showInformationMessage('Aucun éditeur actif trouvé.');
        }
    });

    // Enregistre une commande spécifique pour le mode débogage.
    const disposableAlias = vscode.commands.registerCommand('udes-sqlformatter.FormatterAlias', async () => {
        const editor = vscode.window.activeTextEditor;

        if (editor) {
			let document = editor.document;
			let selection = editor.selection;
			let useSelection = !selection.isEmpty;
    		let inputSql = useSelection ? document.getText(editor.selection) : document.getText();

            const tempFilePath = path.join(os.tmpdir(), 'temp_sql_script.sql');
            const bom = Buffer.from([0xEF, 0xBB, 0xBF]);
            const sqlBuffer = Buffer.concat([bom, Buffer.from(inputSql, 'utf-8')]);
            fs.writeFileSync(tempFilePath, sqlBuffer);

            const scriptPath = path.join(__dirname, '..', 'powershell', 'Exec-Format-SQL.ps1');

			// Commande pour le mode débogage.
            const command = `powershell.exe -ExecutionPolicy Bypass -File "${scriptPath}" -inputFile "${tempFilePath}" -addAlias`;

            exec(command, (error, stdout, stderr) => {
                fs.unlinkSync(tempFilePath);

                if (error) {
                    vscode.window.showErrorMessage(`Erreur : ${error.message}`);
                    return;
                }
                if (stderr) {
                    vscode.window.showErrorMessage(`Erreur standard : ${stderr}`);
                    return;
                }
				let formattedSql = stdout;

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
                });
            });
        } else {
            vscode.window.showInformationMessage('Aucun éditeur actif trouvé.');
        }
    });

    // Ajoute toutes les commandes enregistrées aux abonnements pour nettoyage.
	context.subscriptions.push(disposable);
	context.subscriptions.push(disposableInLine);
    context.subscriptions.push(disposableAlias);
}
