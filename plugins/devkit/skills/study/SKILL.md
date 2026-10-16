---
description: Étudie le projet (stack, architecture, conventions, patterns, commandes, pièges) et écrit .devkit/PATTERNS.md, que les agents devkit lisent avant de travailler. Mise à jour incrémentale si le fichier existe déjà ; `full` force une étude complète.
argument-hint: "[full]"
context: fork
agent: general-purpose
model: opus
background: false
---

Produis ou mets à jour `.devkit/PATTERNS.md`. Chaque agent le lit avant
de travailler : il doit être exact, concret et court (environ 150 lignes).
Chaque affirmation vient de fichiers lus, pas de ce qu'un projet de ce type
contient d'habitude.

Tu tournes dans un contexte séparé : tu ne vois pas la conversation de
l'utilisateur, et ton dernier message lui sera transmis par la session
principale.

Arguments reçus : « $ARGUMENTS »

## Mode

- `PATTERNS.md` n'existe pas, ou les arguments contiennent `full` : étude
  complète.
- Sinon, mise à jour. Lis la ligne `Commit étudié` en haut du fichier, puis
  `git log --oneline <hash>..HEAD` et `git diff --stat <hash>..HEAD`. Réétudie
  seulement ce que ces changements touchent (nouvelles dépendances, nouveaux
  dossiers, nouveau pattern) et mets à jour les sections concernées.
  - Le hash n'existe plus dans l'historique, ou plus de la moitié des fichiers
    source ont changé : fais une étude complète.
  - Rien de significatif n'a changé : mets seulement l'en-tête à jour et
    dis-le.

## Étude complète

Pour ne pas remplir ton contexte, rassemble les faits en lançant en parallèle
des agents `devkit:explorer`, un par zone :

1. **Stack et commandes** : manifestes (package.json, composer.json,
   pyproject.toml, go.mod…), scripts, CI, Dockerfile, fichiers de config.
2. **Architecture** : arborescence, couches, points d'entrée, modules, et le
   chemin d'une vraie requête de bout en bout.
3. **Conventions et patterns** : nommage, gestion d'erreurs, validation, accès
   aux données, injection de dépendances, avec deux ou trois exemples
   représentatifs (`fichier:ligne`) pour chacun.
4. **Tests** : framework, emplacement, commande, fichier de test représentatif.

Sur un petit projet (moins d'une trentaine de fichiers source), fais l'étude
toi-même, sans agents.

## Vérifier

Les rapports des explorers citent leurs `fichier:ligne` : reprends leurs
affirmations telles quelles. Vérifie toi-même **5 points au plus**, en lisant
seulement les lignes citées, et uniquement :

- les problèmes de sécurité (secrets, auth) ;
- les pièges qui touchent la production ;
- les affirmations douteuses, ou contradictoires entre deux rapports.

Ne lance ni build, ni lint, ni suite de tests pour vérifier : chaque appel
relit tout ton contexte, et il grossit à chaque fichier lu.

## Rédiger

Choisis ce qui compte avant d'écrire, puis écris PATTERNS.md **en une seule
fois**. Ne le retouche pas ensuite pour gagner quelques lignes : 170 lignes
utiles valent mieux que dix retouches. Ne retouche que pour corriger une
erreur.

Ne recopie jamais la valeur d'un secret (clé, mot de passe, token) :
PATTERNS.md est commité et partagé. Cite seulement l'emplacement
(`fichier:ligne`).

## Format de PATTERNS.md

```
# Patterns du projet

> Commit étudié : <hash court> · <YYYY-MM-DD> · généré par /devkit:study

## Stack
Langage, framework et versions principales ; base de données, ORM, services
externes.

## Commandes
| Action | Commande |
|---|---|
| Installer | … |
| Lancer en dev | … |
| Build | … |
| Tests (tous / un seul fichier) | … |
| Lint / format | … |

## Architecture
Les dossiers qui comptent et le rôle de chaque couche. Le chemin d'une requête
typique, de l'entrée jusqu'à la base.

## Conventions
Nommage (fichiers, classes, fonctions), structure d'un module, imports, règles
imposées par la config (lint, formatter).

## Patterns récurrents
Pour chacun : ce qu'il fait en une phrase, et un fichier de référence à imiter
(`chemin/fichier.ts:ligne`). Par exemple : gestion d'erreurs, validation des
entrées, accès aux données, auth.

## Tests
Framework, emplacement et nommage des fichiers, fichier de test de référence à
imiter.

## Pièges connus
Ce qu'un nouveau développeur casserait sans le savoir : ordre d'initialisation,
fichiers générés à ne pas éditer, variables d'environnement requises,
conventions implicites. Écris « aucun repéré » plutôt que d'en inventer.

## Zones sensibles
Le code où une erreur coûte cher (auth, paiement, données personnelles,
migrations) et qui demande plus de vigilance.
```

Omets une section qui ne s'applique pas au projet plutôt que de la remplir de
généralités.

## Après l'écriture

Termine par un résumé de cinq lignes au plus : ce que tu as trouvé de plus
utile (surtout les pièges et les zones sensibles) et le chemin du fichier.

Si tu as constaté des bugs (du code qui ne fait pas ce qu'il devrait, pas un
simple piège), ajoute après le résumé une section **Bugs constatés** : pour
chacun, fichier:ligne, symptôme, gravité proposée. La session principale les
enregistrera dans `.devkit/BUGS.md`. Les problèmes de sécurité (secrets
exposés, route sans contrôle d'accès…) vont dans une section **Failles
constatées**, au même format, pour `.devkit/SECURITY.md`. Si
le projet a un `CLAUDE.md` qui ne mentionne pas encore PATTERNS.md, ajoute
au résumé qu'une ligne pourrait y renvoyer, sans modifier CLAUDE.md
toi-même.
