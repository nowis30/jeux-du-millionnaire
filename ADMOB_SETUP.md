# Configuration AdMob - Héritier Millionnaire

## 📱 Configuration Android

### Identifiants AdMob configurés:
- **App ID**: `ca-app-pub-7443046636998296~8556348720`
- **Interstitial Ad Unit ID**: `ca-app-pub-7443046636998296/7243267055`

### Fichiers modifiés:
1. ✅ `android/app/build.gradle` - Ajout du SDK Google Mobile Ads
2. ✅ `android/app/src/main/AndroidManifest.xml` - Ajout de l'App ID AdMob
3. ✅ `android/app/src/main/java/com/heritier/millionnaire/AdMobPlugin.java` - Plugin Capacitor personnalisé
4. ✅ `android/app/src/main/java/com/heritier/millionnaire/MainActivity.java` - Enregistrement du plugin

## 🚀 Utilisation dans le code

### 1. Importer le plugin

```typescript
import AdMob from '@/mobile/src/admob';
```

### 2. Initialiser AdMob au démarrage de l'app

```typescript
// Dans _app.tsx ou layout.tsx
useEffect(() => {
  if (Capacitor.isNativePlatform()) {
    AdMob.initialize()
      .then(() => console.log('AdMob initialized'))
      .catch(err => console.error('AdMob init error:', err));
  }
}, []);
```

### 3. Charger une annonce interstitielle

```typescript
async function loadAd() {
  try {
    await AdMob.loadInterstitial();
    console.log('Ad loaded successfully');
  } catch (error) {
    console.error('Failed to load ad:', error);
  }
}
```

### 4. Afficher l'annonce

```typescript
async function showAd() {
  try {
    const { ready } = await AdMob.isAdReady();
    if (ready) {
      await AdMob.showInterstitial();
      console.log('Ad shown');
      // Après que l'ad se ferme, rechargez-en une nouvelle
      await AdMob.loadInterstitial();
    } else {
      console.log('No ad ready to show');
    }
  } catch (error) {
    console.error('Failed to show ad:', error);
  }
}
```

## 💡 Stratégies recommandées

### Quand afficher les annonces interstitielles:

1. **Après avoir encaissé dans un quiz**
   ```typescript
   // Dans la route /quiz POST /cash-out
   if (Capacitor.isNativePlatform()) {
     await AdMob.showInterstitial();
   }
   ```

2. **Après avoir acheté/vendu une propriété**
   ```typescript
   // Après une transaction immobilière réussie
   if (amount > 10000 && Capacitor.isNativePlatform()) {
     await AdMob.showInterstitial();
   }
   ```

3. **Après X questions dans un quiz**
   ```typescript
   // Après chaque 5 questions, par exemple
   if (questionNumber % 5 === 0 && Capacitor.isNativePlatform()) {
     await AdMob.showInterstitial();
   }
   ```

### ⚠️ Bonnes pratiques:

- **Précharger**: Chargez la prochaine annonce dès que la précédente est fermée
- **Limiter la fréquence**: N'affichez pas d'annonces trop souvent (max 1 toutes les 2-3 minutes)
- **Vérifier la disponibilité**: Toujours vérifier avec `isAdReady()` avant d'afficher
- **Gestion des erreurs**: Prévoyez un fallback si l'annonce ne charge pas

## 🔧 Build et test

### 1. Sync Capacitor
```bash
cd mobile
npm run sync
```

### 2. Ouvrir dans Android Studio
```bash
npm run android
```

### 3. Build l'APK
Dans Android Studio:
- Build → Build Bundle(s) / APK(s) → Build APK(s)

### 4. Tester sur un appareil réel
⚠️ **Important**: Les annonces de test ne s'affichent pas toujours dans l'émulateur. Testez sur un appareil réel.

## 📊 Mode Test vs Production

### IDs de test (pour le développement):
Pour tester sans utiliser vos vrais IDs, utilisez:
```java
// Dans AdMobPlugin.java, remplacez temporairement par:
private static final String INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-3940256099942544/1033173712";
```

### IDs de production (actuels):
Les IDs configurés sont vos vrais IDs AdMob. Les revenus seront réels.

## 🎯 Next Steps

1. **Intégrer dans le code client**:
   - Ajouter l'initialisation dans `_app.tsx` ou le layout principal
   - Ajouter les appels `showInterstitial()` aux endroits stratégiques

2. **Test sur appareil réel**:
   - Build l'APK
   - Installer sur un téléphone Android
   - Tester le chargement et l'affichage des annonces

3. **Monitoring**:
   - Vérifier dans la console AdMob que les impressions sont comptabilisées
   - Ajuster la fréquence selon le taux de remplissage

## 📞 Résolution de problèmes

### L'annonce ne se charge pas:
- Vérifiez que les IDs sont corrects dans `AdMobPlugin.java`
- Vérifiez la connexion Internet de l'appareil
- Consultez les logs Android Studio (Logcat)

### L'annonce ne s'affiche pas:
- Vérifiez avec `isAdReady()` avant d'appeler `showInterstitial()`
- Attendez quelques secondes après `loadInterstitial()` avant d'afficher

### Erreur "Ad failed to load":
- Normal pendant les tests (faible inventaire pour les comptes neufs)
- Ajoutez un compteur d'essais avec délai exponentiel
