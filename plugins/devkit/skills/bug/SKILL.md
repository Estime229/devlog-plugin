---
description: Liste des bugs constatés du projet dans .devkit/BUGS.md — enregistrer un bug, lister les bugs ouverts, en corriger un avec l'agent debugger, ou le clôturer. À utiliser aussi dès qu'un agent, une étude ou l'utilisateur signale un bug qui ne sera pas corrigé tout de suite.
argument-hint: "[description | list | fix BUG-xxx | close BUG-xxx raison]"
---

Tu tiens la liste des bugs constatés du projet, dans `.devkit/BUGS.md`.

Arguments reçus : « $ARGUMENTS »

- vide ou `list` : **lister**
- `fix BUG-xxx` : **corriger**
- `close BUG-xxx …` : **clôturer**
- autre chose : **enregistrer** le bug décrit

## Format de BUGS.md

À la création, le fichier commence par :

```
# Bugs constatés

Statuts : 🔴 ouvert · 🟡 en cours · 🟢 corrigé · ⚪ écarté
Gravité : critique · haute · moyenne · basse
```

Chaque bug est une section, ajoutée à la fin du fichier :

```
### BUG-001 · 🔴 ouvert · haute — Titre compréhensible seul
**Constaté le** : YYYY-MM-DD · **Par** : utilisateur | devkit:test-writer | /devkit:study | …
**Fichier(s)** : `chemin/fichier.ts:42`
**Symptôme** : ce qu'on observe, en une ou deux phrases
**Reproduire** : étapes, commande ou test — ou « non reproduit »
**Cause supposée** : hypothèse, ou « inconnue »
```

Le statut et la gravité sont sur la ligne de titre : `grep '^### BUG-'` donne
la liste complète, et `grep '🔴'` les bugs ouverts. Garde ce format exact.

Une faille de sécurité ne va pas ici : enregistre-la dans
`.devkit/SECURITY.md` (skill `devkit:security`).

Gravité :
- **critique** : perte de données, production cassée
- **haute** : une fonction importante ne marche pas, sans contournement
- **moyenne** : ça ne marche pas, mais on peut contourner
- **basse** : gêne mineure, cosmétique

## Enregistrer

1. Crée `.devkit/BUGS.md` avec son en-tête s'il n'existe pas.
2. Cherche un doublon (même fichier, même symptôme). S'il existe, complète
   l'entrée existante au lieu d'en créer une.
3. Prends l'ID suivant (le plus grand BUG-xxx + 1, sur trois chiffres) et
   ajoute la section. Un titre qui se comprend seul : pas « bug auth », mais
   « Le login renvoie 500 quand l'email contient une majuscule ».
4. Ne recopie jamais la valeur d'un secret : BUGS.md est commité.

Plusieurs bugs à la fois (rapport d'agent, résumé d'étude) : enregistre-les
tous, puis donne la liste des IDs créés.

## Lister

Affiche les bugs 🔴 et 🟡, du plus grave au moins grave : ID, gravité, titre,
fichier. Termine par le nombre de bugs corrigés et écartés.

## Corriger

1. Passe le bug à 🟡 en cours.
2. Lance `devkit:debugger` avec la section complète du bug.
3. Selon son rapport :
   - **correction appliquée** : lance `devkit:test-writer` avec la section
     **À tester**. Si les tests montrent que le bug est toujours là, renvoie
     son rapport au debugger. Après deux allers-retours sans succès, arrête-toi
     et explique la situation à l'utilisateur.
   - **correction proposée** : présente-la à l'utilisateur et demande s'il
     veut l'appliquer. Si elle touche plusieurs fichiers, confie-la à
     `devkit:feature-dev`.
   - **non reproduit** : repasse le bug à 🔴, ajoute ce qui a été essayé dans
     **Reproduire**, et dis-le à l'utilisateur.
4. Une fois la correction vérifiée, journalise-la selon le skill devlog : une
   entrée 🐛 BUG avec la ligne `**Bug** : BUG-xxx`.
5. Clôture le bug en 🟢 corrigé (voir ci-dessous).

Les « autres bugs constatés » du rapport du debugger s'enregistrent comme
nouveaux bugs.

## Clôturer

Change le statut sur la ligne de titre, puis ajoute sous l'entrée :

- 🟢 corrigé :
  `**Corrigé le** : YYYY-MM-DD · **Journal** : [titre de l'entrée](chemin-relatif#ancre)`
  et `**Correction** : ce qui a été fait, en une phrase`
- ⚪ écarté : `**Écarté le** : YYYY-MM-DD — raison` (pas un bug,
  comportement voulu, ne sera pas corrigé…)

Le lien vers le journal part de `.devkit/` : `journal/CHANGELOG.md#ancre`, ou
`../.claude/session-log.md#ancre` si le projet utilise session-log.md.
