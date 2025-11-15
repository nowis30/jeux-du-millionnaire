# Dépannage : Serveur indisponible pour résultats de course

## Symptôme
Message "Serveur indisponible" lors de l'envoi des résultats de course drag racing.

## Diagnostic rapide (Console navigateur F12)

### 1. Vérifier le serveur
```javascript
fetch('https://server-jeux-millionnaire.onrender.com/healthz')
  .then(r => r.json())
  .then(console.log)
// Attendu: {"status":"ok"}
```

### 2. Vérifier l'authentification
```javascript
// Token auth (si connecté)
console.log('Token:', localStorage.getItem('hm-token'));

// Session drag
console.log('Session:', localStorage.getItem('hm-session'));

// Test auth
fetch('https://server-jeux-millionnaire.onrender.com/api/auth/me', {
  credentials: 'include',
  headers: {
    'Authorization': 'Bearer ' + localStorage.getItem('hm-token')
  }
}).then(r => r.json()).then(console.log)
```

### 3. Vérifier les parties disponibles
```javascript
fetch('https://server-jeux-millionnaire.onrender.com/api/games')
  .then(r => r.json())
  .then(console.log)
// Devrait retourner au moins 1 partie
```

### 4. Test complet de la session drag
```javascript
// Réinitialiser et tester
localStorage.removeItem('hm-session');
location.reload();
// Puis jouer une course et observer les erreurs réseau dans l'onglet Network
```

## Causes fréquentes

### A. Pas de partie active
**Symptôme** : `/api/games` retourne `{"games": []}`

**Solution** : Créer une partie via l'interface admin ou API :
```bash
curl -X POST https://server-jeux-millionnaire.onrender.com/api/games \
  -H "Content-Type: application/json" \
  -d '{"name":"Partie principale","code":"MAIN"}'
```

### B. Authentification guest échouée
**Symptôme** : Erreur 401 sur `/api/games/:id/join`

**Solution** : Vérifier que le middleware `requireUserOrGuest` autorise bien les guests. Le cookie `hm_guest` doit être défini.

### C. Serveur Render en veille
**Symptôme** : Premier appel très lent (> 30s) puis timeout

**Solution** : Render met les services gratuits en veille après 15 min d'inactivité. Solutions :
- Attendre ~1 min que le serveur se réveille
- Upgrade vers plan payant
- Ping régulier (cron job externe)

### D. CORS bloqué
**Symptôme** : Erreur CORS dans la console

**Solution** : Vérifier les origines autorisées dans `server/src/index.ts` :
```typescript
app.register(fastifyCors, {
  origin: [
    'https://client-jeux-millionnaire.vercel.app',
    'https://www.nowis.store',
    'http://localhost:5173',
    // Ajouter votre domaine si nécessaire
  ],
  credentials: true
});
```

## Actions immédiates

1. **Ouvrir la console navigateur** (F12 → Console + Network)
2. **Jouer une course** et observer les requêtes réseau
3. **Noter l'erreur exacte** (code 401/403/404/500/timeout)
4. **Vérifier l'onglet Network** : quelle requête échoue en premier ?

## Fix rapide : Forcer une session manuelle

Si le problème persiste, ajoutez ceci avant de jouer :

```javascript
// Dans la console F12 :
localStorage.setItem('hm-session', JSON.stringify({
  gameId: 'GAME_ID_ICI',  // Remplacer par un vrai ID de partie
  playerId: 'PLAYER_ID_ICI', // Remplacer par votre player ID
  nickname: 'Test'
}));
location.reload();
```

Pour obtenir un gameId/playerId valide :
1. Connectez-vous à l'app principale Millionnaire
2. Copiez votre session depuis `localStorage.getItem('hm-session')`
3. Collez dans le jeu drag

## Logs serveur

Si vous avez accès aux logs Render :
1. Render Dashboard → Service "server-jeux-millionnaire"
2. Onglet "Logs"
3. Cherchez les erreurs 500/400 pendant que vous testez

## Besoin d'aide ?

Si aucune solution ne fonctionne, envoyez :
- **Screenshot de la console** (F12 → onglets Console + Network)
- **Résultat de** : `localStorage.getItem('hm-session')`
- **Navigateur/OS** : Chrome/Firefox/Safari sur Windows/Mac/Android ?
