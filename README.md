## Liens de déploiement

- API (Render): https://server-jeux-millionnaire.onrender.com
- Client (Vercel): https://client-jeux-millionnaire.vercel.app

# Héritier Millionnaire — Monorepo

Monorepo pour le jeu de simulation économique multijoueur « Héritier Millionnaire ».

- client: Next.js + React + TypeScript + Tailwind (interface)
- server: Node.js + Fastify + Prisma + Socket.IO + node-cron (API & temps réel)
- shared: Types et constantes communes

## Nouveautés (nov. 2025)

- **Nettoyage automatique des ticks**: Un cron job s'exécute toutes les 20 minutes pour optimiser la base de données. Il conserve les 100 derniers ticks de chaque symbole + 1 tick sur 100 des anciens (échantillonnage pour historique). Cela évite l'accumulation excessive (avec 360 ticks/heure, on peut atteindre 8640 ticks/jour par symbole).
 - **Tutoriel complet**: Voir `TUTORIEL_JEU.md` pour un guide structuré (gameplay, quiz, refill immobilier, stratégie, anatomy).
- Dividendes trimestriels: versés le dernier jour ouvrable de mars, juin, septembre et décembre.
- **HUD Drag synchronisé**: Le mini-jeu Drag (standalone et `/drag` côté client) n'affiche plus les boutons login/logout; il détecte automatiquement la session via `/api/auth/me`, affiche l'email authentifié ou l'état invité, et le service worker a été régénéré via `npm run pipeline:drag`.
- Cache mémoire (~90s) sur les endpoints marché: `GET /api/games/:id/markets/latest` et `GET /api/games/:id/markets/returns` (bypass possible avec `?debug=1`).
- UI allégée:
	- Tableau de bord: flux d'activité retiré; rafraîchissements manuels.
	- Bourse: graphique historique supprimé; KPI dividendes en rafraîchissement à la demande.
	- Projections portefeuille/immobilier calculées à la demande (bouton).
	- Univers marché réduit à 5 actifs (SP500, QQQ, TSX, GLD, TLT) pour accélérer le chargement.

## Pré-requis

- Node.js 18+
- PostgreSQL local

## Variables d’environnement

Créez un fichier `server/.env` à partir de `server/.env.example`.

```env
DATABASE_URL=postgres://postgres:postgres@localhost:5432/heritier
PORT=3001
CRON_TICK=0 * * * *     # chaque heure
TIMEZONE=America/Toronto
NODE_ENV=development
CLIENT_ORIGIN=http://localhost:3000
JWT_SECRET=dev-secret
ADMIN_EMAIL=admin@example.com
```

Pour le client, vous pouvez définir `client/.env.local` si l’API n’est pas sur `http://localhost:3001` :

```env
NEXT_PUBLIC_API_BASE=http://localhost:3001
```

## Installation

npm run prisma:generate -w server
Exécutez à la racine du monorepo:

```powershell
npm install
```

Initialisez Prisma (nécessite PostgreSQL opérationnel) :

Option A — via Docker (recommandé pour local) :

```powershell
# Démarrer Postgres en conteneur
npm run db:up
# (optionnel) suivre les logs
# npm run db:logs
```

Option B — Postgres installé localement :
- Assurez-vous que le service écoute sur `localhost:5432` et que l’utilisateur/mot de passe/base
	correspondent à `server/.env` (par défaut postgres/postgres/heritier).

```powershell
# À la racine (exécute les scripts côté server)
npm run prisma:generate -w server
# optionnel: créer la base et appliquer les migrations
# npm run prisma:migrate -w server -- --name add-guest-id
# seed des données de base (10 immeubles)
# npm run seed -w server
```

## Démarrage

En développement, lancez l’API (et ensuite le client):

```powershell
npm run dev -w server
# dans un autre terminal
npm run dev -w client
```

- API: http://localhost:3001
- Web client: http://localhost:3000

## Déploiement (Docker Compose, tout-en-un)

Un `docker-compose.prod.yml` est fourni avec 4 services: Postgres, API (server), client Next.js et Nginx (reverse proxy).

Ports exposés:
- 80 (Nginx):
	- `/` → client Next.js
	- `/api` et `/socket.io` → API Fastify
- 3000 (client) et 3001 (API) sont exposés aussi pour debug local.

Commandes:

```powershell
# Build et lancement (Windows PowerShell, depuis la racine)
docker compose -f docker-compose.prod.yml up --build -d

# Logs
docker compose -f docker-compose.prod.yml logs -f server
docker compose -f docker-compose.prod.yml logs -f client

# Arrêt
docker compose -f docker-compose.prod.yml down
```

Assurez-vous d’ajuster `CLIENT_ORIGIN` et `NEXT_PUBLIC_API_BASE` pour votre domaine en production.

## Déploiement géré (optionnel)

- Client: Vercel (Next.js) — définir `NEXT_PUBLIC_API_BASE=https://<votre-api>/` (ou `/api` si reverse proxy)
- API: Railway/Render/Render — exposer le port 3001; définir `CLIENT_ORIGIN=https://<votre-client>` et `JWT_SECRET`, `ADMIN_EMAIL`, `TIMEZONE`
- Postgres: service managé (Railway/Neon/Supabase) — mettre à jour `DATABASE_URL`.

### Check‑list post‑déploiement (Render + Vercel)

1) API (Render)
	- DATABASE_URL = (Postgres managé)
	- PORT = 3001 (ou valeur imposée par la plateforme)
	- CLIENT_ORIGIN = https://<votre-domaine-client>
	- JWT_SECRET = <secret long et aléatoire>
	- ADMIN_EMAIL = <email administrateur>
	- TIMEZONE = America/Toronto (ou votre TZ)
	- CRON_TICK = 0 * * * * (tick horaire par défaut)
	- Redéployer à partir de la branche main

2) Client (Vercel)
	- NEXT_PUBLIC_API_BASE = https://<votre-api> (URL complète de l'API Render)
	- Redéployer la production

3) Validation rapide
	- Ouvrir https://<client>/ et créer/rejoindre une partie (lobby → running)
	- Bourse: voir les prix actuels (latest) et les rendements; vérifier que le KPI dividendes se rafraîchit à la demande
	- Immobilier: achats/ventes OK; projections calculées à la demande
	- Dashboard: pas de flux d’activité, boutons de rafraîchissement fonctionnent
	- Si besoin de contourner le cache marchés: ajouter `?debug=1` aux URLs marché

4) Redémarrage admin (destructif)
	- Se connecter avec l’email `ADMIN_EMAIL`
	- Sur le tableau de bord, utiliser le bouton « Redémarrer » de la partie (envoie `POST /api/games/:id/restart`)
	- Si 401/403: se reconnecter (JWT < 12h), vérifier `CLIENT_ORIGIN` (CORS/CSRF) et l’email admin côté serveur

	## Application mobile (Android)

	- Un wrapper Capacitor est fourni dans `mobile/` qui charge l'URL du client (Vercel) dans une WebView.
	- Côté API, ajoutez `capacitor://localhost` à `CLIENT_ORIGIN` pour autoriser l'origine mobile.

	Étapes rapides:
	- `npm install --prefix mobile`
	- (optionnel) définir `MOBILE_WEB_URL` pour surcharger l'URL Vercel
	- `npm run sync --prefix mobile`
	- `npm run android --prefix mobile` pour ouvrir Android Studio et générer un APK

## PWA (Mobile)

L’app web est installable sur mobile (PWA):
- Manifest: `client/public/manifest.webmanifest`
- Service Worker: généré par `next-pwa` en production
- Metadata: `client/app/layout.tsx` référence le manifest et le theme color

Sur iOS/Android:
- Ouvrez le site (via Nginx, port 80) → “Ajouter à l’écran d’accueil”.
- Ajoutez des icônes 192x192 et 512x512 dans `client/public/icons/` pour un rendu optimal.

## Scripts utiles

- `npm run dev -w server` — démarre Fastify avec rechargement
- `npm run dev -w client` — démarre Next.js en dev
- `npm run build` — build server et client
- `npm run start -w server` — démarre l’API (prod)
- `npm run test:smoke -w server` — exécute un test smoke des annonces (listings)

### Scripts d'admin

- `scripts/admin-restart.ps1` — déclenche un redémarrage de partie (admin)
- `scripts/restart-game.js` — redémarre une partie en se connectant directement à la base de données (nécessite `.env` avec l'URL externe de la base)
- `scripts/cleanup-ticks-manual.js` — nettoie manuellement les ticks de marché (garde 100 derniers + 1/100 anciens)

Usage PowerShell (restart via API):

```powershell
./scripts/admin-restart.ps1 -ApiBase "https://server-jeux-millionnaire.onrender.com" -GameId "<id-partie>" -BearerToken "<votre-jwt>"
```

Usage Node.js (restart direct DB):

```powershell
# 1. Créer scripts/.env avec DATABASE_URL=<URL_EXTERNE_POSTGRES>
# 2. Exécuter depuis le dossier server
cd server
node ../scripts/restart-game.js
```

Usage Node.js (nettoyage ticks manuel):

```powershell
# 1. Créer scripts/.env avec DATABASE_URL=<URL_EXTERNE_POSTGRES>
# 2. Exécuter depuis le dossier server
cd server
node ../scripts/cleanup-ticks-manual.js
```

Notes:
- Le JWT admin est valable ~12h; si vous obtenez 401, reconnectez-vous côté client et copiez un token frais depuis les outils de développement (onglet Réseau → requêtes API → en-tête Authorization).
- Le serveur tolère un en-tête anti‑CSRF (`X-CSRF: 1`) envoyé par le script.
- Pour les scripts Node.js directs, utilisez l'URL **External Database URL** de Render (pas l'URL Internal)
- Le nettoyage automatique des ticks s'exécute toutes les 20 minutes via cron job, mais vous pouvez aussi le déclencher manuellement

## API REST

- `POST /api/games` — créer une partie (option hostNickname pour créer l'hôte lié au cookie invité)
- `GET /api/games?status=lobby` — lister les parties ouvertes
- `POST /api/games/:id/join` — rejoindre une partie (lié au cookie invité)
- `POST /api/games/code/:code/join` — rejoindre une partie via son code (lié au cookie invité)
- `POST /api/games/:id/start` — lancer la simulation
- `GET /api/games/:id/state` — récupérer l’état et les joueurs
- `GET /api/games/:id/summary` — résumé instantané (classement courant)
- `GET /api/games/:id/me` — récupérer votre joueur courant (via cookie invité)
- `GET /api/properties/templates` — lister les immeubles disponibles
- `POST /api/games/:id/properties/purchase` — acheter un immeuble
- `POST /api/games/:id/properties/:holdingId/refinance` — refinancer
- `POST /api/games/:id/properties/:holdingId/sell` — vendre et récupérer le cash
- `GET /api/games/:id/markets/latest` — prix simulés des actifs
- `GET /api/games/:id/markets/returns?window=1d|7d|30d` — rendements agrégés par fenêtre
- `GET /api/games/:id/markets/holdings/:playerId` — portefeuille boursier
- `POST /api/games/:id/markets/buy` — acheter un actif
- `POST /api/games/:id/markets/sell` — vendre un actif
- `POST /api/games/:id/restart` — redémarrer une partie (admin uniquement; en-tête Authorization Bearer requis)
- `POST /api/games/:id/cleanup-ticks` — nettoyer les ticks de marché (admin uniquement; garde 100 derniers + 1/100 anciens)
- `GET /api/games/:id/diagnostic` — obtenir les statistiques de la base de données pour une partie (admin uniquement)
  
### Annonces P2P (Listings)

- `GET /api/games/:gameId/listings` — lister les annonces de la partie
- `POST /api/games/:gameId/listings` — créer une annonce (body: { sellerId, holdingId|templateId, price })
- `POST /api/games/:gameId/listings/:id/cancel` — annuler une annonce (body: { sellerId })
- `POST /api/games/:gameId/listings/:id/accept` — accepter une annonce (body: { buyerId })
## OpenAPI

Un fichier OpenAPI minimal est disponible: `server/openapi/openapi.yml`. Vous pouvez l’ouvrir dans Swagger Editor (web) ou une extension VS Code pour prévisualiser la documentation. Les schémas sont volontairement concis et couvrent les opérations principales.

Une UI Swagger est exposée par l’API en local:

- http://localhost:3001/docs

## Mode de jeu

- Le jeu est continu (sans fin). Les parties passent de `lobby` à `running` et peuvent tourner indéfiniment.
- Les routes de mutation (achats/ventes/annonces/immobilier) sont bloquées quand la partie n’est pas en état `running`.

### Dividendes

- Fréquence: trimestrielle (dernier jour ouvrable de mars/juin/septembre/décembre)
- Les distributions s’ajoutent au cash des joueurs détenteurs à la date de versement

### Cache marché

- Cache mémoire TTL ≈ 90 secondes sur `latest` et `returns`
- Débogage: ajouter `?debug=1` pour bypass le cache temporairement

## Tests (smoke)

Quelques tests de fumée sont fournis pour valider les flux principaux (requiert PostgreSQL opérationnel et Prisma configuré):

```powershell
npm run test:smoke -w server          # Listings (P2P)
npm run test:smoke:market -w server   # Marché (achat/vente)

```


Notes:
- MVP: seuls les listings de biens existants (holdingId) sont supportés; les listings de template ne sont pas encore activés.
- Les actions émettent des événements en temps réel (Socket.IO) : `listing:create`, `listing:cancel`, `listing:accept`.

## Structure

```
/client   → Next.js + Tailwind (interface)
/server   → Node.js + Prisma + Socket.IO + cron
/shared   → Types et constantes communes
```

## Notes

- Les migrations Prisma ne sont pas exécutées automatiquement. Configurez `DATABASE_URL` puis lancez `prisma migrate` si nécessaire.
- Nouveau: Auth invité par cookie (hm_guest) — le serveur assigne automatiquement un cookie. Les routes de création/join lient votre joueur à ce cookie. Sur les pages Immobilier/Bourse, le joueur est résolu automatiquement via `/api/games/:id/me` si l'ID n'est pas encore connu.
- Le cron exécute `hourlyTick()` selon `CRON_TICK`.
- Le tableau de bord web mémorise la session (gameId/playerId) dans `localStorage` pour faciliter l’enchaînement entre les pages Immobilier et Bourse.
- Les pages web permettent de créer/rejoindre une partie, d’acheter des immeubles et de trader les actifs du marché. La page “Annonces” (P2P) permet de publier un bien, d’annuler ou d’acheter via annonce, avec rafraîchissement en temps réel.