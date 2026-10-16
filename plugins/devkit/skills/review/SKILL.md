---
description: Fait relire les changements en cours par l'agent reviewer (sonnet), en les comparant aux conventions de .devkit/PATTERNS.md, puis propose de corriger les remarques. Lecture seule tant que l'utilisateur n'a pas accepté les corrections.
argument-hint: "[fichiers ou dossier]"
---

Arguments reçus : « $ARGUMENTS »

1. Lance `devkit:reviewer` sur le périmètre : les fichiers ou le dossier passés
   en argument, sinon tous les changements non commités. S'il n'y a aucun
   changement, dis-le et arrête-toi.
2. Présente les remarques à l'utilisateur, groupées par gravité (bloquant, à
   corriger, suggestion), avec leur `fichier:ligne`.
3. Propose de corriger les remarques bloquantes et « à corriger ». Si
   l'utilisateur accepte, corrige toi-même les petites, et confie à
   `devkit:feature-dev` celles qui touchent plusieurs fichiers.
4. Si le rapport recommande un audit de sécurité, propose
   `/devkit:security diff`.
5. Un bug remarqué hors du périmètre de la relecture s'enregistre dans
   `.devkit/BUGS.md` (skill `devkit:bug`).
