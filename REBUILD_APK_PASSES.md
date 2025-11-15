# 🎯 Rebuilder l'APK avec le système de passes

## ✅ Synchronisation faite !

Les changements ont été synchronisés avec Capacitor.

## 🔨 Étapes pour rebuilder l'APK :

### Dans Android Studio (si ouvert) :
1. **Build → Clean Project**
2. **Build → Build Bundle(s) / APK(s) → Build APK(s)**
3. Attendre 2-3 minutes
4. L'APK sera dans : `mobile/android/app/build/outputs/apk/debug/app-debug.apk`

### Si Android Studio n'est pas ouvert :
```powershell
cd "C:\Users\smori\OneDrive\Documents\application nouvelle\jeux du Millionaire\mobile"
npx cap open android
```
Puis suivre les étapes ci-dessus.

## 🆕 Nouvelles fonctionnalités dans cet APK :

### Système de passes de vie :
- **Bouton "📺 Pub → +1 Passe"** : Regarder une pub pour obtenir une passe
- **Compteur de passes** : Affiché en haut du quiz (✨ Passes de vie: X)
- **Seconde chance** : Quand vous vous trompez, si vous avez une passe :
  - Modal s'affiche : "Voulez-vous utiliser une passe pour continuer ?"
  - ✓ Utiliser → Vous continuez le quiz
  - ✗ Refuser → Le quiz se termine normalement

### Publicités intégrées :
- **Pub après encaissement** : Automatique quand vous encaissez
- **Pub pour passes** : Volontaire, donne +1 passe de vie

## 📱 Comment tester :

1. **Installer le nouvel APK** sur un téléphone Android
2. **Lancer le jeu** et aller dans Quiz
3. **Cliquer sur "📺 Pub → +1 Passe"**
   - Une pub devrait s'afficher
   - Après la pub, vous gagnez +1 passe
4. **Jouer au quiz** et répondre volontairement faux
5. **Modal de seconde chance** devrait apparaître
6. **Cliquer "Utiliser une passe"** → Le quiz continue !

## 🔄 Mise à jour GitHub Releases :

Une fois l'APK testé :
1. Renommer : `heritier-millionnaire-passes-20251109.apk`
2. Uploader sur : https://github.com/nowis30/jeux-millionnaire-APK/releases
3. Remplacer l'ancien APK ou créer une nouvelle release

## 💡 Astuce :

Si vous voulez tester rapidement sans rebuilder :
- Le site web Vercel sera mis à jour automatiquement
- Mais les pubs ne fonctionneront que sur l'APK Android natif
- Le bouton sera visible partout, mais marquera "indisponible" sur web

---

**🎯 Action suivante : Rebuilder l'APK dans Android Studio**
