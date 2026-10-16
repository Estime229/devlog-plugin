---
description: Prépare un projet pour devkit — crée .devkit/ (journal, routing.md, .gitignore), migre l'ancien journal, propose de relier CLAUDE.md et d'activer devkit pour l'équipe, puis de lancer la première étude.
disable-model-invocation: true
---

Prépare le projet pour devkit. Si `.devkit/` existe déjà, dis ce qui est en
place et ne complète que ce qui manque. Ne remplace aucun fichier existant.

## 1. Créer .devkit/

- `.devkit/.gitignore` :

  ```
  .journal-index-count
  .journal-reminded
  ```

- `.devkit/routing.md` :

  ```
  # Routage des agents devkit

  Règles propres à ce projet. Elles priment sur les modèles par défaut des
  agents ; sans règle ici, les défauts s'appliquent (voir le README devkit).

  ## Modèles

  <!-- Exemple : - devkit:test-writer → opus (code de paiement critique) -->

  ## Règles

  <!-- Exemple : - Toute modification de src/payment/ est suivie de /devkit:security diff -->
  ```

## 2. Le journal

- `.claude/session-log.md` existe : c'est le journal du projet, ne crée rien.
- `.claude/journal/CHANGELOG.md` existe : propose de le déplacer, ce qui
  supprime les demandes d'approbation à chaque écriture dans `.claude/` :

  ```bash
  mkdir -p .devkit && git mv .claude/journal .devkit/journal
  ```

  Applique seulement si l'utilisateur accepte.
- Sinon, crée `.devkit/journal/CHANGELOG.md` :

  ```
  # Journal

  Changements significatifs du projet (features, bugs, refactors, sécurité),
  par date. Tenu par devkit : /devkit:log, /devkit:journal-index.
  ```

`BUGS.md` et `SECURITY.md` se créent d'eux-mêmes au premier bug ou au premier
audit.

## 3. CLAUDE.md

Propose d'ajouter ce bloc au `CLAUDE.md` du projet (ou de créer le fichier),
pour que chaque session le lise. Applique seulement si l'utilisateur accepte :

```
## devkit

- Avant de modifier le code, lis `.devkit/PATTERNS.md` : conventions, pièges
  connus, zones sensibles.
- Bugs constatés : `.devkit/BUGS.md` · failles : `.devkit/SECURITY.md` ·
  journal : `.devkit/journal/CHANGELOG.md`.
```

## 4. L'équipe

Si `.claude/settings.json` n'active pas déjà devkit, montre le bloc à y
ajouter pour que toute l'équipe l'ait. Ne modifie pas ce fichier toi-même : il
est partagé, et Claude Code protège le dossier `.claude/`.

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

## 5. Première étude

Propose de lancer `/devkit:study`. Préviens qu'une étude complète prend
quelques minutes et coûte quelques dollars sur un gros projet ; elle ne se
refait ensuite que sur les nouveaux commits.

Termine par la liste de ce qui a été créé, et de ce qui attend une réponse de
l'utilisateur.
