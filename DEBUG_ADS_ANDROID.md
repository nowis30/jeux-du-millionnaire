# 🔧 Debug Publicités Android - Guide complet

## ✅ Corrections appliquées

Le code a été corrigé pour accéder au plugin via `Capacitor.Plugins.AdMob` au lieu de `window.AdMob`.

## 📱 Comment tester et déboguer

### Étape 1 : Rebuilder l'APK avec les corrections

1. **Ouvrir Android Studio**
   ```powershell
   cd "C:\Users\smori\OneDrive\Documents\application nouvelle\jeux du Millionaire\mobile"
   npx cap open android
   ```

2. **Vérifier que Gradle sync est terminé**
   - Attendre la barre de progression en bas

3. **Clean et Rebuild**
   - Build → Clean Project
   - Build → Rebuild Project
   - Build → Build Bundle(s) / APK(s) → Build APK(s)

4. **Installer le nouvel APK**
   - Copier `mobile/android/app/build/outputs/apk/debug/app-debug.apk`
   - L'installer sur le téléphone Android

### Étape 2 : Activer les logs (mode développeur)

#### Sur le téléphone Android :
1. **Activer le débogage USB** :
   - Paramètres → À propos du téléphone
   - Tapper 7 fois sur "Numéro de build"
   - Retour → Options pour les développeurs
   - Activer "Débogage USB"

2. **Connecter en USB** au PC

3. **Vérifier la connexion** :
   ```powershell
   adb devices
   ```
   Devrait afficher votre appareil

#### Dans Android Studio :
1. **Ouvrir Logcat** (onglet en bas)
2. **Filtrer** par :
   - `AdMobPlugin` : Logs du plugin natif Java
   - `Ads` : Logs du code JavaScript
   - `Capacitor` : Logs généraux Capacitor

### Étape 3 : Tester les pubs

1. **Lancer l'app** sur le téléphone
2. **Regarder les logs** dans Logcat
3. **Au démarrage**, devrait voir :
   ```
   [Capacitor] Loading app...
   [Ads] AdMob initialized successfully
   [AdMobPlugin] AdMob initialized
   [AdMobPlugin] Interstitial ad loaded
   ```

4. **Aller dans Quiz**
5. **Cliquer sur "📺 Pub → +1 Passe"**
6. **Logs attendus** :
   ```
   [Ads] Interstitial ad shown successfully
   [AdMobPlugin] Interstitial ad showed
   ```

## ❌ Messages d'erreur possibles

### "AdMob plugin not available"
**Cause** : Le plugin n'est pas enregistré ou Capacitor ne le trouve pas
**Solution** :
1. Vérifier `MainActivity.java` :
   ```java
   registerPlugin(AdMobPlugin.class);
   ```
2. Rebuilder complètement

### "Failed to load ad: No fill"
**Cause** : Compte AdMob neuf ou pas d'inventaire publicitaire
**Solutions** :
- Attendre 24-48h que Google approuve le compte
- Utiliser des IDs de test temporairement

### "No ad ready to show"
**Cause** : L'annonce n'a pas été chargée ou a échoué
**Solution** :
- Vérifier les logs pour voir l'erreur de chargement
- Attendre quelques secondes et réessayer

## 🧪 Utiliser des IDs de test AdMob

Pour tester sans attendre l'approbation Google :

### Modifier `AdMobPlugin.java` :
```java
// Remplacer temporairement l'ID par l'ID de test Google
private static final String INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-3940256099942544/1033173712";
```

Puis rebuilder et tester. Les pubs de test s'afficheront immédiatement.

### Remettre votre vrai ID après test :
```java
private static final String INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-7443046636998296/7243267055";
```

## 📊 Vérifier dans la console AdMob

1. **Aller sur** : https://apps.admob.com
2. **Applications** → Héritier Millionnaire
3. **Statistiques** → Vérifier les impressions (délai 24-48h)

## 🔍 Checklist de débogage

- [ ] Plugin AdMobPlugin bien dans MainActivity.java
- [ ] App ID dans AndroidManifest.xml
- [ ] Google Mobile Ads SDK dans build.gradle
- [ ] APK rebuil

dé après les dernières modifs
- [ ] Installé sur téléphone réel (pas émulateur)
- [ ] Connexion Internet active
- [ ] Logs Logcat activés
- [ ] Message "AdMob initialized" dans les logs
- [ ] Attendre 24-48h si compte AdMob neuf

## 💡 Logs de diagnostic à partager

Si ça ne marche toujours pas, copiez ces logs depuis Logcat :
```
1. Logs au démarrage (filtre: Ads|AdMobPlugin)
2. Logs quand vous cliquez sur le bouton pub
3. Toute ligne contenant "error" ou "failed"
```

---

**🎯 Prochaine action : Rebuilder l'APK et tester avec Logcat ouvert**
