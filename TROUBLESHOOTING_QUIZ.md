# 🐛 Quiz - Guide de dépannage

## Symptôme: "Rien ne se passe quand je clique sur le bouton Quiz"

### Diagnostics rapides

#### 1. Vérifier que le serveur est démarré

```bash
# Dans le terminal du serveur, vous devriez voir :
cd server
npm run dev

# Logs attendus :
# [timestamp] HTTP server listening (port: 3001)
```

**Si le serveur n'est pas démarré** :
```bash
cd server
npm run dev
```

---

#### 2. Vérifier que le client est démarré

```bash
# Dans un autre terminal :
cd client
npm run dev

# Ouvrir http://localhost:3000
```

---

#### 3. Vérifier les logs de la console navigateur

**Ouvrir la console** (F12 ou Cmd+Option+I sur Mac)

**Logs normaux attendus** :
```
[Quiz] Game ID from localStorage: clxxxxxx
[Quiz] Loading status for game: clxxxxxx
[Quiz] Status response: 200 OK
[Quiz] Status data: { canPlay: true, tokens: 1, ... }
```

**Erreurs possibles** :

##### Erreur: `Game ID from localStorage: null`
```
[Quiz] No game ID found, redirecting to home
```

**Solution** :
1. Retourner à l'accueil
2. Rejoindre ou créer une partie
3. Vérifier que vous êtes bien dans la partie
4. Réessayer d'accéder au quiz

---

##### Erreur: `404 Not Found`
```
[Quiz] Status response: 404 Not Found
[Quiz] Status error: { error: "Joueur non trouvé" }
```

**Solution** :
1. Le joueur n'existe pas dans cette partie
2. Retourner à l'accueil et rejoindre la partie correctement
3. Vérifier dans le serveur que le joueur existe :

```bash
cd server
node scripts/test-quiz-api.js
```

---

##### Erreur: `CORS` ou `Network error`
```
Access to fetch at '...' from origin '...' has been blocked by CORS policy
```

**Solution** :
1. Vérifier que `CLIENT_ORIGINS` dans `server/.env` inclut `http://localhost:3000`
2. Redémarrer le serveur

```bash
# Dans server/.env
CLIENT_ORIGINS=http://localhost:3000,http://localhost:3001
```

---

##### Erreur: `Connection refused`
```
Failed to fetch
net::ERR_CONNECTION_REFUSED
```

**Solution** :
Le serveur n'est pas démarré. Voir étape 1.

---

#### 4. Vérifier que les questions existent

```bash
cd server
npm run build
node scripts/test-quiz-api.js
```

**Output attendu** :
```
✅ Partie active trouvée: ABC123
✅ Joueur trouvé: VotreNom
   Tokens: 1
📊 Questions disponibles:
   Faciles: 10
   Moyennes: 10
   Difficiles: 15
```

**Si aucune question** :
```bash
node scripts/seed-quiz.js
```

---

#### 5. Vérifier les tokens du joueur

```sql
-- Se connecter à PostgreSQL
psql heritier

-- Vérifier les tokens
SELECT nickname, "quizTokens", "lastTokenEarnedAt"
FROM "Player"
WHERE "gameId" IS NOT NULL;
```

**Si tokens = 0** :
```sql
-- Donner 1 token manuellement
UPDATE "Player"
SET "quizTokens" = 1
WHERE nickname = 'VotreNom';
```

---

## Problèmes courants

### Problème: Page blanche

**Causes possibles** :
1. Erreur JavaScript non gérée
2. Route Next.js incorrecte

**Solution** :
1. Ouvrir la console (F12)
2. Chercher les erreurs en rouge
3. Vérifier que le fichier existe : `client/app/quiz/page.tsx`

---

### Problème: "Joueur non trouvé"

**Causes** :
1. Le cookie `HM_GUEST_ID` n'est pas envoyé
2. Le joueur n'existe pas dans la partie
3. Mauvais `gameId` dans localStorage

**Solution** :
```javascript
// Dans la console du navigateur :
console.log(localStorage.getItem("HM_GAME_ID"));
console.log(document.cookie);

// Devrait afficher:
// HM_GUEST_ID=guest_xxxxx
```

Si le cookie est absent :
1. Retourner à l'accueil
2. Rejoindre la partie à nouveau

---

### Problème: Le bouton ne fait rien

**Vérifier dans le code source de la page** (View Source) :

```html
<!-- Doit contenir un lien vers /quiz -->
<a href="/quiz">💰 Quiz</a>
```

**Si le lien est correct mais rien ne se passe** :
1. Vérifier qu'il n'y a pas d'erreur JavaScript qui bloque
2. Ouvrir la console et chercher des erreurs
3. Tester en navigation directe : `http://localhost:3000/quiz`

---

### Problème: "Pas assez de tokens"

**Si vous venez de créer le joueur** :

Le joueur devrait avoir 1 token par défaut. Vérifier :

```sql
SELECT "quizTokens" FROM "Player" WHERE nickname = 'VotreNom';
```

**Si = 0, donner 1 token** :
```sql
UPDATE "Player" SET "quizTokens" = 1 WHERE nickname = 'VotreNom';
```

**Pour tester l'accumulation** :
```sql
-- Simuler 5 heures écoulées
UPDATE "Player"
SET "lastTokenEarnedAt" = NOW() - INTERVAL '5 hours'
WHERE nickname = 'VotreNom';

-- Recharger la page quiz, devrait avoir 6 tokens (1 + 5)
```

---

## Tests manuels

### Test 1: Vérifier l'API directement

```bash
# Remplacer GAME_ID et GUEST_ID par vos valeurs
curl http://localhost:3001/api/games/GAME_ID/quiz/status \
  --cookie "HM_GUEST_ID=GUEST_ID" \
  -H "X-CSRF: 1"
```

**Réponse attendue** :
```json
{
  "canPlay": true,
  "hasActiveSession": false,
  "tokens": 1,
  "secondsUntilNextToken": 3540
}
```

---

### Test 2: Démarrer une session

```bash
curl -X POST http://localhost:3001/api/games/GAME_ID/quiz/start \
  --cookie "HM_GUEST_ID=GUEST_ID" \
  -H "X-CSRF: 1" \
  -H "Content-Type: application/json"
```

**Réponse attendue** :
```json
{
  "sessionId": "clxxxx",
  "currentQuestion": 1,
  "currentEarnings": 0,
  "securedAmount": 0,
  "nextPrize": 1000,
  "question": {
    "id": "clyyyy",
    "text": "Quelle est...",
    "optionA": "...",
    "optionB": "...",
    "optionC": "...",
    "optionD": "..."
  }
}
```

---

## Logs serveur à surveiller

**Logs normaux** :
```
[tokens] Joueur clxxx a consommé 1 token. Reste: 0
[Quiz] Session créée pour joueur clxxx
[Quiz] Question sélectionnée: clyyyy (easy)
```

**Logs d'erreur** :
```
[Quiz] Erreur: Joueur non trouvé
[Quiz] Erreur: Pas assez de tokens
[Quiz] Erreur: Aucune question disponible
```

Si vous voyez `Aucune question disponible` :
```bash
cd server
node scripts/seed-quiz.js
```

---

## Checklist complète

Avant de signaler un bug, vérifier :

- [ ] Serveur démarré (`npm run dev` dans `server/`)
- [ ] Client démarré (`npm run dev` dans `client/`)
- [ ] Dans une partie active (pas dans le lobby)
- [ ] Joueur créé et visible dans la partie
- [ ] Questions seedées (au moins 10 de chaque difficulté)
- [ ] Tokens disponibles (au moins 1)
- [ ] Pas d'erreur dans la console navigateur
- [ ] Pas d'erreur dans les logs serveur
- [ ] Cookie `HM_GUEST_ID` présent
- [ ] `localStorage` contient `HM_GAME_ID`

---

## Commandes utiles

```bash
# Voir tous les joueurs avec leurs tokens
cd server
npx prisma studio
# Ouvrir le modèle Player

# Réinitialiser les tokens pour tester
node -e "
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
prisma.player.updateMany({ data: { quizTokens: 5 } }).then(() => {
  console.log('Tous les joueurs ont maintenant 5 tokens');
  prisma.\$disconnect();
});
"

# Voir les logs en temps réel
# (Dans le terminal du serveur, ils apparaissent automatiquement)

# Tester l'API complète
node scripts/test-quiz-api.js
```

---

## Support

Si le problème persiste après avoir suivi ce guide :

1. **Copier les logs de la console navigateur** (F12 > Console > Clic droit > Save as)
2. **Copier les logs du serveur** (dernières 50 lignes)
3. **Copier la sortie de** `node scripts/test-quiz-api.js`
4. **Indiquer les étapes exactes** pour reproduire le problème

---

**Dernière mise à jour** : Novembre 2025
