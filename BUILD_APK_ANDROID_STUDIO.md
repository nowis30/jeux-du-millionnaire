# Solution : Builder l'APK via Android Studio (RECOMMANDÉ)

## ❌ Problème : Java/JDK non configuré dans PATH

Le build en ligne de commande nécessite Java/JDK configuré, mais c'est compliqué.

## ✅ Solution simple : Utiliser Android Studio directement

### Android Studio est DÉJÀ OUVERT, suivez ces étapes :

1. **Attendre que Gradle finisse de synchroniser** (regarder la barre de progression en bas)
   - Message : "Gradle sync in progress..."
   - Attendre que ce soit "Gradle sync finished"

2. **Builder l'APK :**
   - Menu : **Build → Build Bundle(s) / APK(s) → Build APK(s)**
   - Ou raccourci : **Build → Make Project** (Ctrl+F9)

3. **Attendre la fin du build** (2-5 minutes la première fois)
   - Notification apparaîtra en bas à droite : "APK(s) generated successfully"

4. **Localiser l'APK :**
   - Cliquer sur "locate" dans la notification
   - OU aller manuellement dans : `mobile\android\app\build\outputs\apk\debug\app-debug.apk`

5. **Renommer et copier l'APK :**
   - Copier `app-debug.apk`
   - Le renommer en : `heritier-millionnaire-admob-20251109.apk`
   - Le mettre à la racine du projet

## 📱 Étapes suivantes :

### Option A : Test sur téléphone Android via câble USB
1. Activer "Débogage USB" sur le téléphone : Paramètres → Options développeur
2. Connecter le téléphone en USB
3. Dans Android Studio : **Run → Run 'app'** (Shift+F10)
4. L'app s'installe et se lance automatiquement

### Option B : Transfert manuel de l'APK
1. Copier l'APK sur le téléphone (email, Drive, câble USB)
2. Ouvrir le fichier APK sur le téléphone
3. Autoriser l'installation depuis cette source
4. Installer et lancer

## 🧪 Tester les annonces AdMob :

1. Ouvrir l'app sur le téléphone
2. Jouer au quiz
3. Répondre à quelques questions
4. Cliquer sur "Encaisser"
5. **Une annonce interstitielle devrait apparaître !**

## 📊 Vérifier les logs (si besoin) :

Dans Android Studio, onglet **Logcat** en bas :
- Filtrer par : `AdMobPlugin` ou `Ads`
- Messages attendus :
  - `[AdMobPlugin] AdMob initialized`
  - `[AdMobPlugin] Interstitial ad loaded`
  - `[AdMobPlugin] Interstitial ad showed`

## 🚀 Uploader l'APK sur GitHub Releases :

1. Aller sur : https://github.com/nowis30/jeux-millionnaire-APK/releases
2. Cliquer "Draft a new release"
3. Tag : `admob-v1.0`
4. Title : `Héritier Millionnaire avec AdMob v1.0`
5. Uploader l'APK
6. Publier la release
7. Copier l'URL du fichier APK
8. Mettre à jour `NEXT_PUBLIC_APK_URL` dans `.env.local`

---

## ⚡ Alternative : Installer Java JDK (optionnel)

Si vous voulez vraiment utiliser la ligne de commande :

1. Télécharger Java JDK 17 : https://adoptium.net/
2. Installer
3. Configurer JAVA_HOME :
   ```powershell
   $env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot"
   $env:PATH += ";$env:JAVA_HOME\bin"
   ```
4. Relancer : `.\build-apk.ps1 debug`

Mais Android Studio est plus simple !

---

**🎯 VOUS ÊTES ICI : Android Studio est ouvert, prêt à builder l'APK**

**👉 Prochaine action : Dans Android Studio → Build → Build Bundle(s) / APK(s) → Build APK(s)**
