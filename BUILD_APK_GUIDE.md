# Guide Build APK Android avec AdMob

## ✅ Étape 1 : Sync Capacitor (FAIT)
```bash
cd mobile
npx cap sync
```

## 📱 Étape 2 : Ouvrir Android Studio (EN COURS)
Android Studio devrait s'ouvrir automatiquement. Si ce n'est pas le cas :
```bash
npx cap open android
```

## 🔨 Étape 3 : Builder l'APK dans Android Studio

### Option A : APK Debug (recommandé pour test)
1. Dans Android Studio : **Build → Build Bundle(s) / APK(s) → Build APK(s)**
2. Attendre la fin du build (quelques minutes)
3. Cliquer sur "locate" dans la notification
4. L'APK sera dans : `mobile/android/app/build/outputs/apk/debug/app-debug.apk`

### Option B : APK Release (signé pour production)
1. Vérifier que vous avez un keystore configuré dans `gradle.properties`
2. Dans Android Studio : **Build → Build Bundle(s) / APK(s) → Build APK(s)**
3. Choisir "release"
4. L'APK sera dans : `mobile/android/app/build/outputs/apk/release/app-release.apk`

### Option C : Build en ligne de commande
```bash
cd mobile/android
# Debug APK
./gradlew assembleDebug

# Release APK (si keystore configuré)
./gradlew assembleRelease
```

## 📦 Étape 4 : Installer l'APK sur un téléphone Android

### Via câble USB :
```bash
# Activer le débogage USB sur le téléphone
# Connecter le téléphone en USB
# Installer l'APK
adb install mobile/android/app/build/outputs/apk/debug/app-debug.apk
```

### Via transfert de fichier :
1. Copier l'APK sur le téléphone (email, Drive, câble USB, etc.)
2. Ouvrir le fichier APK sur le téléphone
3. Autoriser l'installation depuis la source
4. Installer

## 🧪 Étape 5 : Tester les annonces

1. Ouvrir l'app sur le téléphone Android
2. Jouer au quiz
3. Répondre à quelques questions
4. Cliquer sur "Encaisser"
5. **Une annonce interstitielle devrait s'afficher !**

## 📊 Vérification AdMob

### Dans Logcat (Android Studio) :
Rechercher les logs :
- `[AdMobPlugin]` - Messages du plugin natif
- `[Ads]` - Messages du système JavaScript

### Dans la console AdMob :
- Aller sur https://apps.admob.com
- Vérifier les impressions dans "Statistiques"
- Les données apparaissent avec 24-48h de délai

## ⚠️ Troubleshooting

### "Ad failed to load"
- Normal pour un nouveau compte AdMob (faible inventaire)
- Attendez quelques heures/jours que Google approuve votre app
- Vérifiez l'ID dans `AdMobPlugin.java` : `ca-app-pub-7443046636998296/7243267055`

### L'annonce ne s'affiche pas
- Vérifiez dans Logcat que le plugin s'initialise : `[AdMobPlugin] AdMob initialized`
- Vérifiez que l'annonce se charge : `[AdMobPlugin] Interstitial ad loaded`
- Attendez au moins 2 minutes entre chaque encaissement (limite de fréquence)

### Crash au démarrage
- Vérifiez que l'App ID est bien dans `AndroidManifest.xml`
- Vérifiez que la dépendance Google Ads est dans `build.gradle`
- Clean & rebuild : **Build → Clean Project** puis **Build → Rebuild Project**

## 🚀 Upload vers GitHub Releases

Une fois l'APK testé et validé :

```bash
# Renommer l'APK avec la date
$date = Get-Date -Format "yyyyMMdd-HHmm"
$apkPath = "mobile/android/app/build/outputs/apk/debug/app-debug.apk"
$newName = "heritier-millionnaire-admob-$date.apk"
Copy-Item $apkPath $newName

# Créer une release sur GitHub
# Uploader le fichier APK
# Mettre à jour NEXT_PUBLIC_APK_URL dans .env.local
```

## 📝 Checklist finale

- [ ] Sync Capacitor OK
- [ ] Android Studio ouvert
- [ ] APK buildé sans erreurs
- [ ] APK installé sur téléphone Android réel
- [ ] Quiz joué et encaissement testé
- [ ] Annonce interstitielle s'affiche correctement
- [ ] Logs AdMob OK dans Logcat
- [ ] APK uploadé sur GitHub Releases
- [ ] URL APK mise à jour dans .env.local
- [ ] Redéployé sur Vercel

---

**Vous êtes à l'étape : Android Studio est en train de s'ouvrir**

Prochaine action : Builder l'APK dans Android Studio
