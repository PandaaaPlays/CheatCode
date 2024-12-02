## Formatteur MariaDB de l'Université de Sherbrooke (VSCode)
### Installation de l'extension
Dans Visual Studio Code, chercher `>vsix` dans la barre de recherche en haut. Choisissez ensuite le fichier .vsix dans le répertoire `udes-sqlformatter`.

### Utilisation de l'extension
Dans un script SQL (s'assurer que le type est défini / que l'extension du fichier est bien .sql), faire un clic droit pour reformatter le fichier dans sa totalité (ou la partie sélectionnée).

### Modification de l'extension
Dans le fichier `udes-sqlformatter`, vous trouverez les fichiers `extension.ts` et `package.json` qui doivent être modifiés pour modifier l'extension. Pour ajouter un bouton, par exemple, les deux doivent spécifier le nouveau bouton. Si vous souhaitez changer le comportement d'un bouton deja existant, il suffit de changer le `extension.ts`.

### Fonctionnement du formattage
Le formattage du SQL (MariaDB) est actuellement fait par le script powershell `Format-MariaDB-SQL.ps1` dans le répertoire `powershell`. Il est possible de modifier ce script uniquement pour changer le comportement du formattage automatique. Il est également possible d'appeler ce script directement sans passer par l'extension.

### Packaging de l'extension
Après que l'extension fut tester via `F5`, vous pouvez générer le fichier .vsix via la commande `vsce package`.