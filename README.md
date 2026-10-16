# devkit

Plugin Claude Code interne 41Devs pour gérer les agents et les skills d'un
projet : des agents spécialisés qui tournent chacun sur le modèle adapté
(opus, sonnet, haiku), une étude du projet qu'ils lisent avant de travailler,
et un journal automatique des features, bugs et refactors.

Anciennement `devlog`. Le dépôt garde son nom `41devs/devlog-plugin`.

## Installation dans un projet

```bash
/plugin marketplace add 41devs/devlog-plugin
/plugin install devkit@devtools-41devs
```

## Activation automatique pour toute l'équipe

Ajoute dans `.claude/settings.json` du projet :

```json
{
  "extraKnownMarketplaces": {
    "devtools-41devs": {
      "source": { "source": "github", "repo": "41devs/devlog-plugin" }
    }
  },
  "enabledPlugins": {
    "devkit@devtools-41devs": true
  }
}
```

## Migration depuis devlog

Le champ `renames` de `marketplace.json` réécrit automatiquement
`devlog@devtools-41devs` en `devkit@devtools-41devs` dans les settings des
projets. Chaque utilisateur doit seulement lancer une fois, après la mise à
jour de la marketplace :

```bash
/plugin install devkit@devtools-41devs
```

Les commandes s'appellent maintenant `/devkit:log` et `/devkit:journal-index`.

Les fichiers de devkit vivent maintenant dans `.devkit/` à la racine du projet,
et non plus dans `.claude/`. Claude Code protège `.claude/` : chaque écriture y
demande une approbation manuelle, et elle est refusée en mode non interactif
(`claude -p`), même avec une règle de permission. Un journal existant dans
`.claude/journal/CHANGELOG.md` reste utilisé tant qu'il n'est pas déplacé. Pour
migrer :

```bash
mkdir -p .devkit && git mv .claude/journal .devkit/journal
```

## Ce que fait le plugin

### Agents

| Agent | Modèle | Rôle |
|---|---|---|
| `devkit:feature-dev` | opus | Nouvelles fonctionnalités, refactors sur plusieurs fichiers |
| `devkit:test-writer` | sonnet | Écrit et lance les tests ; signale les bugs sans toucher au code |
| `devkit:explorer` | haiku | Recherche rapide en lecture seule |

Chaque agent termine par un rapport au même format (`## Rapport — <agent>`),
que la session principale lit pour enchaîner l'étape suivante.

Pour changer le modèle d'un agent dans un projet, crée `.devkit/routing.md`
avec tes règles (par exemple « test-writer sur opus ») : le skill
`orchestrate` le lit et passe le modèle demandé à chaque appel.

### Skills

- **`orchestrate`** (automatique) : décide quand déléguer et à quel agent, et
  enchaîne explorer → feature-dev → test-writer, avec au plus deux
  allers-retours de correction avant de rendre la main.
- **`/devkit:study`** : étudie le projet (stack, architecture, conventions,
  patterns, commandes, pièges, zones sensibles) et écrit
  `.devkit/PATTERNS.md`. Il tourne sur opus dans un sous-agent à
  contexte vierge : il ne voit pas ta conversation et ne la fait pas
  grossir, seul son résumé y revient. Relancé plus tard, il n'analyse que les
  commits depuis la dernière étude ; `/devkit:study full` refait tout.
- **`devlog`** (automatique) : journalise les changements significatifs dans
  `.claude/session-log.md` (si présent) ou `.devkit/journal/CHANGELOG.md`.
- **`/devkit:log`** : force une entrée à partir du `git diff` en cours.
- **`/devkit:journal-index`** : régénère la table des matières du journal.

### Hook `Stop`

Après chaque réponse, rappelle à Claude de journaliser un changement
significatif (au moins 15 lignes ou 2 fichiers, nouveaux fichiers compris)
s'il n'y a aucune entrée du jour, et de régénérer l'index toutes les 5
entrées.

## Fichiers créés dans les projets

| Fichier | Rôle | À commiter ? |
|---|---|---|
| `.devkit/PATTERNS.md` | Étude du projet | Oui, partagé avec l'équipe |
| `.devkit/journal/CHANGELOG.md` | Journal | Oui |
| `.devkit/routing.md` | Modèles propres au projet (optionnel) | Oui |
| `.devkit/.journal-index-count` | Compteur interne du hook | Non (ignoré via `.devkit/.gitignore`) |
| `.devkit/.journal-reminded` | Compteur interne du hook | Non (ignoré via `.devkit/.gitignore`) |

Le hook crée `.devkit/.gitignore` pour ignorer ses deux compteurs : aucun
réglage à faire dans le `.gitignore` du projet.

## Mise à jour

Après modification, incrémente `version` dans
`plugins/devkit/.claude-plugin/plugin.json`, puis :

```bash
git add -A && git commit -m "vX.Y.Z: description du changement"
git push
```

## Validation avant publication

```bash
claude plugin validate .
```
