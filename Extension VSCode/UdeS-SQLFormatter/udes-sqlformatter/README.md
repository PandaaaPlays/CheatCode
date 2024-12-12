## Formatteur MariaDB de l'Université de Sherbrooke (VSCode)
### Installation de l'extension
Dans Visual Studio Code, chercher `>vsix` dans la barre de recherche en haut. Choisissez ensuite le fichier .vsix dans le répertoire `udes-sqlformatter`.

### Utilisation de l'extension
Dans un script SQL (s'assurer que le type est défini / que l'extension du fichier est bien .sql), faire un clic droit pour reformatter le fichier dans sa totalité (ou la partie sélectionnée).

### Modification de l'extension
Dans le fichier `udes-sqlformatter`, vous trouverez les fichiers `extension.ts` et `package.json` qui doivent être modifiés pour modifier l'extension. Pour ajouter un bouton, par exemple, les deux doivent spécifier le nouveau bouton. Si vous souhaitez changer le comportement d'un bouton deja existant, il suffit de changer le `extension.ts`. 

La modification des extensions VSCode est également bien détaillée par microsoft, voir https://code.visualstudio.com/api/get-started/your-first-extension.

Afin debugger l'extension rapidement, il est possible d'ouvrir une fenêtre de VSCode en mode déboggage via `F5` dans le projet `udes-sqlformatter`. Cette page VSCode permet de tester rapidement les changements sans devoir package l'application complète à toutes les fois. Il est également possible d'activer un mode débug en activant la variable de debug dans le fichier `Exec-Format-SQL.ps1` (de false à true), qui montre les étapes du formattage dans le fichier.

Le script powershell doit être bien testé lors de modifications, car la correction d'un bug dans celui-ci peut en entrainer de nouveaux. Assurez-vous de comprendre l'ordre d'execution, ainsi que les Regex utilisées avant de les modifier (https://regexr.com/ peut aider au debuggage).

### Fonctionnement du formattage
Le formattage du SQL (MariaDB) est actuellement fait par le script powershell `Format-SQL.ps1` (lui même appelé par `Exec-Format-SQL.ps1`) dans le répertoire `powershell`. Il est possible de modifier ce script uniquement pour changer le comportement du formattage automatique. Il est également possible d'appeler ce script directement sans passer par l'extension.

### Packaging de l'extension
Après que l'extension fut tester via `F5`, vous pouvez générer le fichier .vsix via la commande `vsce package` (s'assurer d'avoir installé NPM (https://nodejs.org/en) et VSCE (`npm install --global yo generator-code`)).