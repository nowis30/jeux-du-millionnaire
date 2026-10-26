# Héritier Millionnaire — espace de coordination

Ce dépôt rassemble des références **figées à un commit** vers les composants du jeu. Le client actuel est statique sur Vercel; l’API, l’authentification et la base de données utilisent Supabase. Le wrapper Android est maintenu séparément.

| Dossier | Dépôt source | Rôle |
|---|---|---|
| `client` | [client-jeux-millionnaire](https://github.com/nowis30/client-jeux-millionnaire) | Interface Next.js |
| `server` | [server-jeux-millionnaire](https://github.com/nowis30/server-jeux-millionnaire) | Fonctions et migrations Supabase |
| `mobile` | [mobile-jeux-millionnaire](https://github.com/nowis30/mobile-jeux-millionnaire) | Application Android |
| `releases` | [jeux-millionnaire-APK](https://github.com/nowis30/jeux-millionnaire-APK) | Binaires historiques, téléchargement facultatif |

## Installation reproductible

```sh
git clone https://github.com/nowis30/jeux-du-millionnaire.git
cd jeux-du-millionnaire
npm run setup
npm test
```

`setup` récupère les commits enregistrés, sans suivre automatiquement les branches distantes. Les binaires historiques peuvent être volumineux : `npm run setup:releases` les récupère uniquement si nécessaire.

Pour développer le client, installer ses dépendances à partir de son propre dossier, puis lancer `npm run dev:client`. Pour l’API et Android, suivre les README des sous-modules. Les scripts et configurations Prisma/Render de 2025 ne décrivent plus l’architecture de production.

## Maintenance

Faire les corrections dans les dépôts sources et leurs PR, puis mettre à jour ici les références des sous-modules vers les commits approuvés. La CI vérifie la cohérence et la présence des composants. Les tests fonctionnels et builds restent dans chaque dépôt source.

`shared/`, les anciens scripts d’administration et les fichiers Docker/Render sont conservés pour l’historique; ils ne doivent pas être utilisés pour déployer l’API actuelle. La documentation historique est conservée dans [README-legacy-2025.md](docs/README-legacy-2025.md).
