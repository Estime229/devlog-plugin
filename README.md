# devlog-plugin

Plugin Claude Code interne 41Devs : journalisation automatique des features,
bugs, refactors et chores dans un journal Markdown, avec seuil anti-bruit et
table des matières auto-régénérée.

## Installation dans un projet

```bash
/plugin marketplace add 41devs/devlog-plugin
/plugin install devlog@devtools-41devs
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
    "devlog@devtools-41devs": true
  }
}
```

## Ce que fait le plugin

- **Skill `devlog`** : journalise automatiquement les changements significatifs
  (feature, bug, refactor) dans `.claude/session-log.md` (si présent) ou
  `.claude/journal/CHANGELOG.md`.
- **Hook `Stop`** : après chaque tâche, vérifie si un changement significatif
  a été fait sans être loggé, et rappelle à Claude de régénérer l'index tous
  les 5 entrées.
- **Commande `/log`** : force manuellement une entrée à partir du `git diff`
  en cours.
- **Commande `/journal-index`** : régénère la table des matières en haut du
  journal.

## Mise à jour

Après modification, incrémente `version` dans
`plugins/devlog/.claude-plugin/plugin.json`, puis :

```bash
git add -A && git commit -m "vX.Y.Z: description du changement"
git push
```

## Validation avant publication

```bash
claude plugin validate .
```
