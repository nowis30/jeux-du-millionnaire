# Plugin Capacitor DragLauncher

## 📋 Ce qui a été créé

### 1. Plugin TypeScript (`mobile/src/plugins/`)
- **drag-launcher.ts** : Interface du plugin Capacitor
- **drag-launcher-web.ts** : Implémentation web (redirection vers `/drag`)

### 2. Plugin Android (`mobile/android/app/src/main/java/.../`)
- **DragLauncherPlugin.java** : Plugin natif qui lance `DragActivity`
- **DragActivity.java** : Écran Android avec WebView chargeant `file:///android_asset/drag/index.html`

### 3. Composant React (`mobile/components/`)
- **DragButton.tsx** : Bouton clé-en-main pour ouvrir le drag

### 4. Enregistrement
- **MainActivity.java** : Plugin enregistré avec `registerPlugin(DragLauncherPlugin.class)`

---

## 🚀 Utilisation

### Dans ton interface web/React

#### Option A : Utiliser le composant bouton
```tsx
import DragButton from './components/DragButton';

function MenuMiniJeux() {
  return (
    <div>
      <h2>Mini-jeux</h2>
      <DragButton />
    </div>
  );
}
```

#### Option B : Appel direct du plugin
```typescript
import DragLauncher from './src/plugins/drag-launcher';

async function ouvrirDrag() {
  try {
    const result = await DragLauncher.open();
    console.log('Drag ouvert:', result.success);
  } catch (error) {
    console.error('Erreur:', error);
  }
}
```

---

## 🎯 Comportement

### Sur Android/iOS
1. Clic sur le bouton → appel `DragLauncher.open()`
2. Plugin lance `Intent` vers `DragActivity`
3. `DragActivity` ouvre WebView avec drag **local** (`file:///android_asset/drag/`)
4. Jeu chargé instantanément (pas de réseau)

### Sur Web (navigateur)
1. Clic sur le bouton → appel `DragLauncher.open()`
2. Implémentation web redirige vers `/drag`
3. Comportement standard web

---

## 📦 Fichiers générés

**APK de test** : `heritier-millionnaire-plugin-drag.apk`

**Structure du projet** :
```
mobile/
├── src/plugins/
│   ├── drag-launcher.ts          # Interface plugin
│   └── drag-launcher-web.ts      # Implémentation web
├── components/
│   └── DragButton.tsx             # Composant React
└── android/app/src/main/
    ├── assets/drag/               # Jeu local (HTML/JS/CSS)
    └── java/.../
        ├── DragActivity.java      # Écran natif drag
        ├── DragLauncherPlugin.java # Plugin Capacitor
        └── MainActivity.java      # Enregistrement plugin
```

---

## ✅ Avantages

1. **Drag intégré** : Plus besoin d'héberger sur serveur externe
2. **Chargement instantané** : Assets locaux dans l'APK
3. **Expérience native** : Écran dédié paysage, immersif
4. **API unifiée** : Même code TypeScript pour Android et web
5. **Maintenable** : Un seul point d'entrée (`DragLauncher.open()`)

---

## 🔧 Prochaines améliorations possibles

1. **Passer des données** : Envoyer cash/niveau du joueur au drag
   ```java
   intent.putExtra("playerCash", playerCash);
   intent.putExtra("currentStage", stage);
   ```

2. **Récupérer le résultat** : Remonter le score du drag
   ```java
   startActivityForResult(intent, REQUEST_CODE_DRAG);
   ```

3. **Bridge JavaScript** : Communication WebView ↔ Native
   ```java
   webView.addJavascriptInterface(new DragBridge(), "AndroidBridge");
   ```

---

## 📝 Notes

- Le drag utilise toujours ton API backend (Render) pour le classement
- Les fichiers sont synchronisés : `mobile/dist/drag/` → `assets/drag/`
- Orientation paysage forcée dans `AndroidManifest.xml`
- Mode immersif fullscreen pour l'expérience de jeu
