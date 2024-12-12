## Installation de l'outil
### Registres 
Afin d'obtenir les entrées du menu contextuel, il faut ajouter des clés de registre. Attention, il peut être dangereux de modifier les registres deja existant sur la machine, au risque de corrompre des choses et de créer des problèmes sur votre machine. Il est toutefois très facile d'en ajouter des nouveaux, sans modifier le comportement actuel des autres registres. 

L'outil `RegistryKeyManager/Registry-FormApplication.ps1` permet de générer les bons registres pour faire exactement ce qu'on veut dans cet outil. Voici les configurations que je recommande d'utiliser. 
```YAML
Nom : CSVtoSQL
Entree : [UdeS] CSV -> SQL
Associations : .csv
Commande : powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%VOTRE_REPERTOIRE%\code_templates\Outils\PowerShell_Scripts\Form-Application.ps1" "%1"
Icone : %VOTRE_REPERTOIRE%\code_templates\Outils\PowerShell_Scripts\icon.ico
Position : Bottom
```
```YAML
Nom : SQLMerge 
Entree : [UdeS] Merge SQL
Associations : Dossiers
Commande : powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%VOTRE_REPERTOIRE%\code_templates\Outils\PowerShell_Scripts\Form-Application.ps1" "%V"
Icone : %VOTRE_REPERTOIRE%\code_templates\Outils\PowerShell_Scripts\icon.ico
Position : Bottom
```
*À noter qu'il est toujours possible de supprimer / modifier le registre en utilisant les différentes pages de `Registry-FormApplication.ps1`.*

## Utilisation de l'outil
### Form-Application
Lors du clic droit sur un `répertoire (dossier)` ou un `fichier .csv`, un bouton `[UdeS] Outil ...` (différent selon le displayName) sera disponbile en bas du menu contextuel de windows. À noter que sur Windows 11, il est nécessaire de faire `Shift + Clic droit` afin de voir toutes les options. Le clic sur ce bouton d'option ouvrira l'application PowerShell Forms qui permettera à l'utilisateur de facilement modifier les options du script choisi. Il sera ensuite possible d'executer le script de `Merge SQL` ou `CSV` en cliquant sur le bouton `Confirmer`.

## Modification de l'outil
### Form-Application
L'application est simple et les commentaires permettent de savoir quelle partie est faite par quel code. Pour n'importe quel texte avec des accents, il faut utiliser le `Get-FormattedString` pour avoir le bon format. L'application n'utilise pas les paddings qui sont complexe à tester, il serait intéressant d'en mettre si l'application possède un UI plus complexe.

## Debuggage de l'outil
- Si le Form-Application ne fonctionne plus, c'est fort probablement car le path de celui-ci à changé. Lorsque vous le modifier, vous devez également modifier la commande du registre.
- Si vous n'avez pas accès à modifier les registres, c'est que vous n'avez pas parti PowerShell en mode administrateur (n'arrivera plus car le script force le mode Administrateur).
- Si les accent ne sont plus disponibles, assurez-vous que votre fichier PowerShell est encodé en UTF-8, et que vous utilisez la méthode `Get-FormattedString` pour les chaines de caractères avec des accents.