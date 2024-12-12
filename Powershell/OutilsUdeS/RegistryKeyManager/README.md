## Utilisation de l'outil
### Form-Application
Lancez le script de modification de registre `Registry-FormApplication.ps1` afin d'appliquer des modifications sur vos registres. Les boutons sont assez intuitifs et les (i) permettent de donner un peu de contexte aux boutons et champs à remplir. Seul les champs notés d'une étoile (*) sont obligatoires, en plus d'au moins une association.

Si une association n'existe pas et que vous souhaitez l'ajouter, il suffit de l'ajouter dans le fichier `Configuration/PossibleAssociations`. Pour se faire, trouver le chemin d'accès de la clé de registre au préalable (à noter que la plupart des extensions (.txt par exemple) sont gèrés par VSCode s'il est installé). Remplacez également `HKEY_CURRENT_USER` par `HKCU`, `HKEY_LOCAL_MACHINE` par `HKLM`, et ainsi de suite pour le chemin d'accès. Le nom (clé dans le JSON) est utilisé pour afficher une valeur dans le UI, ce qui veut dire que cela peut être n'importe quoi. D'ailleurs, la valeur sera automatiquement bien placé dans le UI afin qu'on puisse ajouter autant de valeurs que souhaité.

## Modification de l'outil
### Form-Application
L'application est simple et les commentaires permettent de savoir quelle partie est faite par quel code. Pour n'importe quel texte avec des accents, il faut utiliser le `Get-FormattedString` pour avoir le bon format. L'application n'utilise pas les paddings qui sont complexe à tester, il serait intéressant d'en mettre si l'application possède un UI plus complexe.

## Debuggage de l'outil
- Si vous n'avez pas accès à modifier les registres, c'est que vous n'avez pas parti PowerShell en mode administrateur (n'arrivera plus car le script force le mode Administrateur).
- Si les accent ne sont plus disponibles, assurez-vous que votre fichier PowerShell est encodé en UTF-8, et que vous utilisez la méthode `Get-FormattedString` pour les chaines de caractères avec des accents.