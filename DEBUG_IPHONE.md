# 🐛 Guide de débogage iPhone/Safari

## Modifications effectuées pour iOS

### Serveur
1. ✅ Middleware `requireUserOrGuest` accepte header `X-Player-ID`
2. ✅ Routes quiz cherchent player via 3 méthodes (header > middleware > cookie)
3. ✅ Route `/join` cherche d'abord par email avant cookie
4. ✅ Toutes routes quiz: `/status`, `/start`, `/answer`, `/cash-out`, `/me`

### Client
1. ✅ `apiFetch()` envoie automatiquement `X-Player-ID` depuis localStorage
2. ✅ Auto-join automatique dès connexion
3. ✅ Page quiz lit `playerId` du localStorage

## Comment déboguer sur iPhone

### Étape 1 : Ouvrir la console Safari
1. Sur iPhone : Réglages > Safari > Avancé > Activer "Inspecteur web"
2. Sur Mac : Safari > Développement > [Votre iPhone] > [Page web]
3. Onglet Console pour voir les logs

### Étape 2 : Vérifier les logs client
Cherchez dans la console :
```
[Quiz] Session from localStorage: ...
[Quiz] Parsed session: ...
[Quiz] Loading status for game: ...
[AutoJoin] Erreur: ...
```

### Étape 3 : Vérifier localStorage
Dans la console Safari, tapez :
```javascript
localStorage.getItem('hm-session')
localStorage.getItem('HM_TOKEN')
```

Résultat attendu :
```json
// hm-session
{"gameId":"xxx","playerId":"yyy","nickname":"email@example.com"}

// HM_TOKEN
"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### Étape 4 : Vérifier les requêtes réseau
1. Onglet Réseau dans Safari
2. Lancez le quiz
3. Cherchez la requête à `/api/games/.../quiz/status`
4. Vérifiez les **headers de requête** :
   - `Authorization: Bearer ...` ✅
   - `X-Player-ID: xxx` ✅
   - `X-CSRF: 1` ✅

### Étape 5 : Tester les étapes individuellement

#### Test 1 : Connexion
```javascript
// Dans la console Safari
fetch('https://server-jeux-millionnaire.onrender.com/api/auth/me', {
  credentials: 'include',
  headers: {
    'Authorization': 'Bearer ' + localStorage.getItem('HM_TOKEN')
  }
}).then(r => r.json()).then(console.log)
```
Attendu : `{id: "xxx", email: "...", isAdmin: false}`

#### Test 2 : Liste des parties
```javascript
fetch('https://server-jeux-millionnaire.onrender.com/api/games', {
  credentials: 'include',
  headers: {
    'Authorization': 'Bearer ' + localStorage.getItem('HM_TOKEN')
  }
}).then(r => r.json()).then(console.log)
```
Attendu : `{games: [{id: "xxx", code: "..."}]}`

#### Test 3 : Mon joueur
```javascript
const session = JSON.parse(localStorage.getItem('hm-session'));
fetch(`https://server-jeux-millionnaire.onrender.com/api/games/${session.gameId}/me`, {
  credentials: 'include',
  headers: {
    'Authorization': 'Bearer ' + localStorage.getItem('HM_TOKEN'),
    'X-Player-ID': session.playerId
  }
}).then(r => r.json()).then(console.log)
```
Attendu : `{player: {id: "xxx", nickname: "email@...", cash: 100000}}`

#### Test 4 : Status quiz
```javascript
const session = JSON.parse(localStorage.getItem('hm-session'));
fetch(`https://server-jeux-millionnaire.onrender.com/api/games/${session.gameId}/quiz/status`, {
  credentials: 'include',
  headers: {
    'Authorization': 'Bearer ' + localStorage.getItem('HM_TOKEN'),
    'X-Player-ID': session.playerId,
    'X-CSRF': '1'
  }
}).then(r => r.json()).then(console.log)
```
Attendu : `{tokens: 1, canPlay: true, hasActiveSession: false, ...}`

## Erreurs communes

### "Unauthenticated"
- ❌ Token JWT manquant ou expiré
- ✅ Solution : Se reconnecter

### "Player not found"
- ❌ playerId dans localStorage incorrect
- ❌ Le joueur n'a pas été créé dans la partie
- ✅ Solution : Effacer localStorage et se reconnecter

### "No game ID found"
- ❌ localStorage vide
- ✅ Solution : Auto-join devrait le remplir automatiquement

### Erreur 403 ou 500
- ❌ Problème serveur
- ✅ Vérifier les logs Render

## Que faire si ça ne marche toujours pas ?

1. **Copier TOUS les logs de la console** Safari
2. **Faire une capture d'écran** de l'erreur
3. **Tester les 4 requêtes** ci-dessus dans la console
4. **Me donner les résultats** pour diagnostic précis

## Déploiement actuel
- Serveur : Commit `495bce9` - "fix: middleware accepte X-Player-ID"
- Délai déploiement Render : ~3 minutes
- Testez après 14h45 (heure actuelle + 3 min)
