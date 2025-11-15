# 🚀 Déploiement Correctif CORS pour Capacitor

## Problème Identifié
L'APK Android ne peut pas se connecter au serveur Render car:
1. ❌ CORS bloque `capacitor://localhost` (origine de l'app mobile)
2. ❌ WebSocket (Socket.IO) bloque aussi cette origine

## Solution Appliquée
Modifications dans `server/src/index.ts` et `server/src/socket.ts`:
- ✅ Ajout de `capacitor://localhost` aux origines autorisées
- ✅ Ajout de `http://localhost` (fallback pour certaines versions de Capacitor)

## 📋 Étapes de Déploiement

### Option 1: Déploiement Direct sur Render (RECOMMANDÉ)

1. **Se connecter à Render Dashboard**
   - Aller sur https://dashboard.render.com
   - Ouvrir le service `server-jeux-millionnaire`

2. **Déployer manuellement**
   - Cliquer sur "Manual Deploy" → "Deploy latest commit"
   - Ou déclencher un redéploiement en modifiant une variable d'environnement

3. **Vérifier les logs**
   - Chercher: `CORS: origines autorisées chargées`
   - Vérifier qu'aucune erreur n'apparaît

### Option 2: Via Git (si le projet est dans un repo)

```bash
# Si vous avez un repo git configuré
git add server/src/index.ts server/src/socket.ts
git commit -m "fix: autoriser Capacitor dans CORS (capacitor://localhost)"
git push

# Render déploiera automatiquement (si auto-deploy activé)
```

### Option 3: Upload Manuel des Fichiers

Si pas de git:
1. Connectez-vous au service Render
2. Accédez au Shell
3. Copiez le contenu de `server/src/index.ts` et `server/src/socket.ts`
4. Redémarrez le service

## 🧪 Test Après Déploiement

### Dans l'APK Android:

1. **Ouvrir la page de test**
   - Naviguer vers `/test-api.html` dans l'app
   - Cliquer sur "Test Connexion Serveur"

2. **Résultat attendu:**
   ```
   ✅ Réponse reçue en XXXms
   Status: 200 OK
   Data: {"csrfToken":"..."}
   ```

3. **Si échec:**
   - Vérifier les logs Render pour voir l'origine rejetée
   - Vérifier que le déploiement s'est bien terminé

### Test du Login:

1. Aller sur `/login`
2. Entrer email/mot de passe
3. Le login devrait maintenant fonctionner ✅

## 📱 Rebuild APK (IMPORTANT)

Après déploiement du serveur, vous devez aussi:

1. **Sync Capacitor:**
   ```bash
   cd mobile
   npx cap sync
   ```

2. **Rebuild APK dans Android Studio:**
   - Build → Clean Project
   - Build → Rebuild Project
   - Build → Build Bundle(s) / APK(s) → Build APK(s)

3. **Installer le nouvel APK sur le téléphone**

## 🔍 Debugging

Si le problème persiste après déploiement:

### Vérifier l'origine envoyée par Capacitor:

Dans `client/lib/api.ts`, ajouter temporairement:
```typescript
console.log('Origin sent:', window.location.origin);
console.log('Protocol:', window.location.protocol);
console.log('Host:', window.location.host);
```

### Vérifier les logs Render:

Chercher dans les logs:
```
CORS origin refusé
```

Si vous voyez une autre origine que `capacitor://localhost`, ajoutez-la au code serveur.

## 📝 Origines Actuellement Autorisées

Après ce correctif, le serveur autorise:
- ✅ `https://jeux-du-millionaire.vercel.app` (production)
- ✅ `*.vercel.app` (previews)
- ✅ `http://localhost:*` (dev local)
- ✅ `capacitor://localhost` (app Android/iOS)
- ✅ `http://localhost` (fallback Capacitor)
- ✅ Requêtes sans origine (server-to-server)

## ⚠️ Notes Importantes

1. **Cookies dans Capacitor:**
   - Les cookies HTTP peuvent ne pas fonctionner dans Capacitor
   - On s'appuie sur le header `x-player-id` pour l'identification
   - Le CSRF est toléré pour les origines Capacitor si `x-player-id` présent

2. **HTTPS Requis:**
   - L'app doit communiquer en HTTPS avec Render
   - Le `network_security_config.xml` est déjà configuré

3. **WebSocket:**
   - Socket.IO est aussi modifié pour accepter Capacitor
   - Le multiplayer devrait fonctionner dans l'app

## ✅ Checklist Finale

- [ ] Serveur déployé sur Render
- [ ] Logs Render montrent démarrage OK
- [ ] Test page `/test-api.html` dans APK réussit
- [ ] Login fonctionne dans l'APK
- [ ] Quiz peut être lancé dans l'APK
- [ ] Pubs AdMob s'affichent (déjà testé ✅)
- [ ] Bonus page pub avec récompense fonctionne

---

🎯 **Prochaine Étape:** Tester le login dans l'APK après déploiement serveur
