# 🧪 Guide de Test - Publicités Récompensées

## ✅ Ce qui a été implémenté

### 1. **Page Bonus** (`/bonus`)
- Nouvelle page accessible depuis l'accueil
- Bouton vert "📺 Bonus Gratuit - Gagnez $5,000 !"
- Interface complète avec :
  - Affichage de la récompense ($5,000)
  - Bouton pour regarder la pub
  - Timer de cooldown (5 minutes entre chaque pub)
  - Messages de succès/erreur
  - Animations et feedback visuel

### 2. **Plugin Android** 
- Support complet des Rewarded Ads
- ID de test configuré : `ca-app-pub-3940256099942544/5224354917`
- Méthodes implémentées :
  - `loadRewardedAd()` - Charge la pub
  - `showRewardedAd()` - Affiche la pub et retourne la récompense
  - `isRewardedAdReady()` - Vérifie si une pub est disponible

### 3. **Amélioration pub après encaissement Quiz**
- Délai de 500ms ajouté pour s'assurer que AdMob est initialisé
- Meilleure gestion des erreurs

## 📱 Comment tester

### Étape 1 : Rebuild l'APK

1. **Sync Capacitor** (déjà fait)
2. **Dans Android Studio** : 
   - Attendez que Gradle finisse la sync
   - Build → Build APK(s)
   - Attendez 2-5 minutes

### Étape 2 : Installer sur téléphone

1. Récupérez l'APK :
   ```
   C:\Users\smori\application nouvelle\jeux du Millionaire\mobile\android\app\build\outputs\apk\debug\app-debug.apk
   ```

2. Transférez sur votre téléphone Android

3. Installez l'APK

### Étape 3 : Tester les pubs récompensées

#### Test 1 : Page Bonus (NOUVEAU)

1. **Ouvrez l'app**
2. **Cliquez sur le bouton vert "📺 Bonus Gratuit"** sur la page d'accueil
3. **Attendez** que le bouton devienne actif (peut prendre 5-10 secondes)
4. **Cliquez sur "Regarder la publicité"**
5. **✅ Une pub de test Google devrait s'afficher**
6. **Regardez la pub jusqu'au bout** (30 secondes environ)
7. **Fermez la pub**
8. **✅ Vous devriez voir un message de succès** avec "$5,000 gagnés"

#### Test 2 : Pub après encaissement Quiz

1. **Allez dans Quiz**
2. **Répondez à quelques questions**
3. **Cliquez sur "Encaisser"**
4. **✅ Une pub interstitielle devrait s'afficher** après l'encaissement

#### Test 3 : Cooldown

1. **Regardez une pub récompensée**
2. **Réessayez immédiatement**
3. **✅ Le bouton devrait être grisé** avec un timer "4min 59s"
4. **Attendez 5 minutes** ou changez l'heure du téléphone
5. **✅ Le bouton redevient actif**

## 🐛 Troubleshooting

### La pub ne s'affiche pas

**Vérifications :**
1. ✅ Connexion internet active
2. ✅ Première pub peut prendre 10-30 secondes à charger
3. ✅ Regardez les logs Android Studio :
   ```
   adb logcat | grep AdMob
   ```

**Solutions :**
- Fermez et rouvrez l'app
- Vérifiez que l'ID de test est correct dans `AdMobPlugin.java`
- Attendez 1-2 minutes après ouverture de l'app

### "Pub en chargement..." ne change pas

**Cause :** La pub ne charge pas
**Solution :**
1. Vérifiez votre connexion internet
2. Redémarrez l'app
3. Vérifiez les logs : `adb logcat | grep "AdMob"`

### La récompense n'est pas créditée

**Cause actuelle :** C'est normal ! Le système est **simulé** pour le moment

**TODO pour production :**
```tsx
// Dans client/app/bonus/page.tsx, ligne ~64
// Remplacez :
setReward(REWARD_AMOUNT);

// Par :
const response = await fetch(`${API_BASE}/api/games/${gameId}/players/${playerId}/reward`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ 
    amount: REWARD_AMOUNT, 
    source: 'rewarded_ad' 
  })
});

if (response.ok) {
  setReward(REWARD_AMOUNT);
}
```

## 🔧 Configuration pour la production

### Étape 1 : Créer un vrai Ad Unit ID

1. Allez sur https://apps.admob.google.com
2. Sélectionnez votre app "Héritier Millionnaire"
3. **Ad units** → **Add ad unit**
4. Choisissez **"Rewarded"**
5. Nommez-le : "Bonus Quotidien" ou "Pub Récompensée"
6. **Copiez l'Ad Unit ID** (format: `ca-app-pub-XXXXXXXX/YYYYYY`)

### Étape 2 : Remplacer l'ID de test

Éditez `mobile/android/app/src/main/java/com/heritier/millionnaire/AdMobPlugin.java` :

```java
// Ligne 35 - Remplacez :
private static final String REWARDED_AD_UNIT_ID = "ca-app-pub-3940256099942544/5224354917";

// Par votre vrai ID :
private static final String REWARDED_AD_UNIT_ID = "ca-app-pub-XXXXXXXX/YYYYYY";
```

### Étape 3 : Créer l'endpoint API

Créez un endpoint côté serveur pour créditer l'argent :

```typescript
// server/src/routes/players.ts
app.post('/api/games/:gameId/players/:playerId/reward', async (req, res) => {
  const { gameId, playerId } = req.params;
  const { amount, source } = req.body;

  // Valider
  if (source !== 'rewarded_ad') {
    return res.status(400).json({ error: 'Invalid source' });
  }

  if (amount > 10000) {
    return res.status(400).json({ error: 'Amount too high' });
  }

  // Vérifier cooldown côté serveur
  const player = await prisma.player.findUnique({
    where: { id: playerId },
    select: { lastRewardedAdAt: true }
  });

  if (player?.lastRewardedAdAt) {
    const elapsed = Date.now() - player.lastRewardedAdAt.getTime();
    if (elapsed < 300000) { // 5 minutes
      return res.status(429).json({ error: 'Too soon' });
    }
  }

  // Créditer
  const updated = await prisma.player.update({
    where: { id: playerId },
    data: { 
      cash: { increment: amount },
      lastRewardedAdAt: new Date()
    }
  });

  res.json({ success: true, newCash: updated.cash });
});
```

## 📊 Métriques attendues

### CPM des Rewarded Ads
- **2-5x plus élevé** que les interstitielles
- ~$10-30 CPM en moyenne (vs $2-8 pour interstitielles)

### Engagement utilisateur
- 20-40% des joueurs actifs regardent au moins 1 pub/jour
- Les joueurs peuvent regarder une pub toutes les 5 minutes

### Revenus estimés
- Si 1000 utilisateurs actifs/jour
- 30% regardent 2 pubs/jour = 600 impressions
- À $20 CPM = $12/jour = $360/mois

## 🎯 Prochaines optimisations possibles

1. **Bonus quotidien** : Récompense plus élevée (1ère pub du jour = $10,000)
2. **Multiplicateur** : Regarder 3 pubs = bonus x2
3. **Missions** : "Regardez 5 pubs cette semaine = $50,000"
4. **Boost temporaire** : Pub = +10% gains pendant 1 heure

## ✅ Checklist finale

Avant le déploiement en production :

- [ ] ID de test remplacé par vrai ID AdMob
- [ ] Endpoint API créé et testé
- [ ] Cooldown vérifié côté serveur
- [ ] Logs de pubs implémentés (anti-triche)
- [ ] Limites quotidiennes configurées (optionnel)
- [ ] Build APK release signé
- [ ] Testé sur plusieurs appareils Android
- [ ] Monitoring AdMob configuré

---

**🚀 Bon test !**
