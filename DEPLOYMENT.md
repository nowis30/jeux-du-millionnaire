# Déploiement en ligne (client + serveur)

Ce projet est un monorepo avec:
- `client/`: Next.js 14 (App Router)
- `server/`: Fastify + Prisma + Socket.IO (port 3001)
- `shared/`: Types/constantes partagés

Nous allons déployer:
- Le **client** sur Vercel (recommandé)
- Le **serveur** sur Railway (ou Render/Fly), avec une base **PostgreSQL** managée

## 1) Pré-requis
- Un dépôt GitHub (poussez le code de ce monorepo)
- Comptes Vercel et Railway (ou Render)

## 2) Base de données
- Sur Railway: New > Database > PostgreSQL
- Récupérez l’URL `DATABASE_URL` (format postgresql://user:pass@host:5432/db)

## 3) Déployer le serveur

### Option A — Render (recommandé)

Ce repo contient un fichier `render.yaml` à la racine qui décrit:
- 1 base PostgreSQL (plan gratuit)
- 1 service web Node pour le serveur (`server/`)

Étapes:
1. Sur Render, créez un Blueprint depuis GitHub en pointant vers ce repo
2. Validez le plan gratuit pour la DB et le Web Service
3. Variables d’env du service Web (dans le blueprint ou après déploiement):
  - `CLIENT_ORIGIN` = `https://<ton-projet>.vercel.app,http://localhost:3000`
  - `PORT` = `3001` (déjà dans le blueprint)
  - `DATABASE_URL` est injectée automatiquement via la DB Render (via `fromDatabase`)
4. Déployez
5. Migrations: la commande `start` exécute automatiquement `prisma migrate deploy` (voir `render.yaml`). Si vous avez besoin de forcer manuellement:
  - `npx prisma migrate deploy`
  - (optionnel) seed: `npx tsx prisma/seed.ts`

Notes:
- Les migrations incluent la table `DividendLog` (crédit des dividendes marché). Si vous migrez une base existante, `migrate deploy` s'en occupe.

Remarques:
- Le build utilise Node 20 (fichier `.nvmrc` ajouté)
- Build: `npm ci && npm run prisma:generate && npm run build`
- Start: `node dist/index.js`
- CORS: le serveur accepte les origines listées dans `CLIENT_ORIGIN`, les domaines `*.vercel.app` et `localhost`.

### Option B — Railway (Dockerfile existant)
1. New > Service > Deploy from GitHub Repo > sélectionnez ce repo
2. Laissez la racine; le Dockerfile `server/Dockerfile` sera détecté
3. Vars d’env:
  - `PORT=3001`
  - `DATABASE_URL=...` (Railway Postgres)
  - `CLIENT_ORIGIN=https://<ton-projet>.vercel.app,http://localhost:3000`
4. Build & Deploy
5. Migrations & seed: même commandes que ci-dessus.

## 4) Déployer le client (Vercel)
1. Importer le repo dans Vercel, et choisir le dossier `client/` comme **root**
2. Build Command: `npm run build`
3. Output: `.next`
4. Variables d’environnement:
  - `NEXT_PUBLIC_API_BASE=https://<ton-serveur>.onrender.com` (ou Railway: `.up.railway.app`)
5. Déployez. L’app Next consommera l’API serveur en ligne.

## 5) CORS & Socket.IO
- Le serveur lit `CLIENT_ORIGIN` (séparé par virgules) et accepte aussi automatiquement les domaines `*.vercel.app` et `localhost`.
- Si vous avez un domaine custom, ajoutez-le à `CLIENT_ORIGIN`.

## 6) Vérifications rapides
- Santé API: `GET https://<serveur>/healthz` doit retourner 200
- Page client: http(s)://<client> fonctionne, les pages /immobilier et /listings chargent
- Socket.IO: les mises à jour temps réel fonctionnent (aucune erreur CORS dans la console)
 - Marché:
   - `GET /api/games/:gameId/markets/latest` retourne 20 actifs
   - `GET /api/games/:gameId/markets/history/SP500?years=10` retourne un historique
   - `GET /api/games/:gameId/markets/dividends/:playerId` retourne les KPI (24h/7j/YTD)

## 7) Dépannage
- Erreurs 500 client en dev: tuer le process sur 3000, supprimer `.next`, relancer `npm run dev`
- CORS: ajouter l’URL du client à `CLIENT_ORIGIN` (séparées par virgules)
- BDD: vérifier `DATABASE_URL` et exécuter `npx prisma migrate deploy`

## 8) Variables d’environnement (récap)
- Serveur:
  - `PORT=3001`
  - `DATABASE_URL=...`
  - `CLIENT_ORIGIN=https://votre-app.vercel.app,http://localhost:3000` (liste autorisée)
- Client:
  - `NEXT_PUBLIC_API_BASE=https://<serveur>`

Bon déploiement !
