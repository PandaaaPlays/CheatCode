## Formatteur MariaDB de l'Université de Sherbrooke (IntelliJ)
### Installation du plugin
Dans IntelliJ, aller dans `File > Settings > Plugins > ⚙️ > Install plugin from Disk` et choisir le fichier `zip` dans le répertoire `IntelliJ-UdeS-SQLFormatter\build\distributions`.

### Utilisation de l'extension
Dans un script SQL (s'assurer que le type est défini / que l'extension du fichier est bien .sql), faire un clic droit pour reformatter le fichier dans sa totalité (ou la partie sélectionnée).

### Modification de l'extension
Dans le fichier `IntelliJ-UdeS-SQLFormatter`, vous trouverez les fichiers `src/main/kotlin/FormatSQL` et `src/main/resources/META-INF/plugin.xml` qui doivent être modifiés pour modifier l'extension. Pour ajouter une action (les boutons), par exemple, les deux doivent spécifier la nouvelle action et le comportement souhaité pour celle-ci. Si vous souhaitez changer le comportement d'un bouton deja existant, il suffit de changer le `src/main/kotlin/FormatSQL`.

### Fonctionnement du formattage
Le formattage du SQL (MariaDB) est actuellement fait par le script powershell `Format-MariaDB-SQL.ps1` dans le répertoire `src/main/resources/powershell`. Il est possible de modifier ce script uniquement pour changer le comportement du formattage automatique. Il est également possible d'appeler ce script directement sans passer par l'extension.

### Packaging de l'extension
Après que l'extension fut tester via la configuration gradle `runIde`, vous pouvez générer le fichier .zip via la configuration gradle `buildPlugin`.