---
description: Audit de sécurité par l'agent security-auditor (opus) — `diff` pour les changements en cours, `full` pour tout le projet, ou un chemin. Les failles sont tenues dans .devkit/SECURITY.md ; `fix SEC-xxx` en fait corriger une, `close SEC-xxx` la clôture. À utiliser aussi après une modification d'une zone sensible.
argument-hint: "[diff | full | chemin | list | fix SEC-xxx | close SEC-xxx raison]"
---

Tu tiens l'audit de sécurité du projet, dans `.devkit/SECURITY.md`.

Arguments reçus : « $ARGUMENTS »

- vide ou `diff` : **auditer** les changements non commités (s'il n'y en a
  aucun, dis-le et propose `full`)
- `full` : **auditer** tout le projet
- un chemin : **auditer** ce fichier ou ce dossier
- `list` : **lister**
- `fix SEC-xxx` : **corriger**
- `close SEC-xxx …` : **clôturer**

## Format de SECURITY.md

À la création, le fichier commence par :

```
# Audit de sécurité

Statuts : 🔴 ouvert · 🟡 en cours · 🟢 corrigé · ⚪ accepté (risque assumé)
Gravité : critique · haute · moyenne · basse

Dernier audit complet : aucun
```

Chaque faille est une section, ajoutée à la fin du fichier :

```
### SEC-001 · 🔴 ouvert · critique — Titre compréhensible seul
**Constaté le** : YYYY-MM-DD · **Audit** : full | diff | <chemin>
**Catégorie** : secrets | authentification | autorisation | injection | exposition de données | configuration | dépendances
**Fichier(s)** : `chemin/fichier.ts:42`
**Risque** : ce qu'un attaquant peut faire, concrètement
**Correction proposée** : ce qu'il faut changer
**Certitude** : certain | probable — pourquoi
```

Garde ce format exact : `grep '^### SEC-'` donne la liste, `grep '🔴'` les
failles ouvertes. Ne recopie jamais la valeur d'un secret : SECURITY.md est
commité.

## Auditer

1. Lance `devkit:security-auditor` avec le mode et le périmètre.
2. Pour chaque faille du rapport, cherche un doublon dans SECURITY.md (même
   fichier, même catégorie) : complète l'entrée existante, ou ajoute-en une
   avec l'ID suivant (le plus grand SEC-xxx + 1, sur trois chiffres). Une
   faille déjà 🟢 corrigée qui réapparaît se rouvre en 🔴, avec la date.
3. Après un audit `full`, mets à jour la ligne `Dernier audit complet` avec le
   hash court du commit et la date.
4. Résume à l'utilisateur : nouvelles failles par gravité avec leurs IDs, et
   les **actions humaines** du rapport (révoquer une clé, changer un mot de
   passe) — ni toi ni les agents ne pouvez les faire.

Un audit `full` coûte cher sur un gros projet : propose-le, ne le lance pas de
toi-même sans que l'utilisateur l'ait demandé.

## Lister

Affiche les failles 🔴 et 🟡, de la plus grave à la moins grave : ID, gravité,
catégorie, titre. Ajoute la date du dernier audit complet et le nombre de
failles corrigées et acceptées.

## Corriger

1. Passe la faille à 🟡 en cours.
2. Lance `devkit:feature-dev` avec l'entrée complète : appliquer la correction
   proposée, sans élargir le périmètre.
3. Lance `devkit:security-auditor` en mode diff : « vérifie que SEC-xxx est
   corrigée et que la correction n'ouvre pas d'autre faille ».
4. Si le comportement change (une route renvoie désormais 403, par exemple),
   lance `devkit:test-writer` pour un test qui le prouve.
5. Après deux allers-retours sans succès, arrête-toi et explique la situation
   à l'utilisateur.
6. Journalise selon le skill devlog : une entrée 🔒 SECURITY avec la ligne
   `**Faille** : SEC-xxx`, sans détail exploitable au-delà du nécessaire.
7. Clôture la faille en 🟢 corrigé.

Pour un secret exposé, corriger le code ne suffit pas : il reste dans
l'historique git. Rappelle à l'utilisateur de révoquer et remplacer le secret,
et ne clôture en 🟢 qu'après sa confirmation.

## Clôturer

Change le statut sur la ligne de titre, puis ajoute sous l'entrée :

- 🟢 corrigé :
  `**Corrigé le** : YYYY-MM-DD · **Journal** : [titre de l'entrée](chemin-relatif#ancre)`
  et `**Correction** : ce qui a été fait, en une phrase`
- ⚪ accepté, seulement sur décision explicite de l'utilisateur :
  `**Accepté le** : YYYY-MM-DD — raison, et qui l'a décidé`

Le lien vers le journal part de `.devkit/` : `journal/CHANGELOG.md#ancre`, ou
`../.claude/session-log.md#ancre` si le projet utilise session-log.md.
