# 🎁 Guide des Publicités Récompensées

## Vue d'ensemble

Les **Rewarded Ads** (pubs récompensées) permettent aux utilisateurs de regarder une publicité volontairement pour recevoir une récompense en jeu (argent, bonus, etc.).

## Configuration AdMob

### 1. Créer un Ad Unit ID pour Rewarded Ads

1. Allez sur https://apps.admob.google.com
2. Sélectionnez votre app `Héritier Millionnaire`
3. Cliquez sur "Ad units" → "Add ad unit"
4. Choisissez **"Rewarded"**
5. Configurez:
   - **Nom**: Rewarded Ad Principal
   - **Récompense**: 1 (type: "reward")
6. Notez l'**Ad Unit ID** généré (format: `ca-app-pub-XXXXXXXX/YYYYYY`)

### 2. Mettre à jour le code Android

Éditez `mobile/android/app/src/main/java/com/heritier/millionnaire/AdMobPlugin.java`:

```java
// Remplacez l'ID de test par votre ID réel
private static final String REWARDED_AD_UNIT_ID = "ca-app-pub-XXXXXXXX/YYYYYY";
```

**ID de test** (pour le développement):
- Android: `ca-app-pub-3940256099942544/5224354917`

## Utilisation dans l'UI

### Composant RewardedAdButton

Le composant `RewardedAdButton` est prêt à l'emploi:

```tsx
import RewardedAdButton from '@/components/RewardedAdButton';

function MyPage() {
  const handleReward = async (amount: number) => {
    // Logique pour donner la récompense à l'utilisateur
    console.log(`Utilisateur a gagné $${amount}`);
    
    // Exemple: Ajouter l'argent au joueur via l'API
    // await fetch('/api/players/add-cash', {
    //   method: 'POST',
    //   body: JSON.stringify({ amount })
    // });
  };

  return (
    <div>
      <RewardedAdButton 
        rewardAmount={5000}  // $5,000 de récompense
        onRewardEarned={handleReward}
      />
    </div>
  );
}
```

### Props du composant

| Prop | Type | Description |
|------|------|-------------|
| `rewardAmount` | `number` | Montant en $ que l'utilisateur gagnera |
| `onRewardEarned` | `(amount: number) => void` | Callback appelé quand l'utilisateur gagne |
| `className` | `string` | Classes CSS additionnelles (optionnel) |

## Exemples d'intégration

### 1. Sur la page d'accueil / Tableau de bord

```tsx
// client/app/page.tsx
import RewardedAdButton from '@/components/RewardedAdButton';

export default function Dashboard() {
  const handleReward = async (amount: number) => {
    // Ajouter l'argent au compte du joueur
    try {
      const response = await fetch(`/api/games/${gameId}/players/${playerId}/cash`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ amount, reason: 'Pub récompensée' })
      });
      
      if (response.ok) {
        alert(`🎉 Vous avez gagné $${amount.toLocaleString()} !`);
        // Rafraîchir les données du joueur
      }
    } catch (error) {
      console.error('Erreur:', error);
    }
  };

  return (
    <div className="p-4">
      <h1>Tableau de bord</h1>
      
      {/* Bouton pour gagner de l'argent */}
      <div className="my-4">
        <h2 className="text-lg mb-2">Besoin d'argent ?</h2>
        <RewardedAdButton 
          rewardAmount={5000}
          onRewardEarned={handleReward}
        />
      </div>
    </div>
  );
}
```

### 2. Après une défaite au quiz

```tsx
// client/app/quiz/page.tsx
import { useState } from 'react';
import RewardedAdButton from '@/components/RewardedAdButton';

export default function QuizPage() {
  const [showRewardOption, setShowRewardOption] = useState(false);

  const handleQuizLoss = () => {
    setShowRewardOption(true);
  };

  const handleReward = async (amount: number) => {
    // Donner une seconde chance ou un bonus de consolation
    alert(`Vous avez gagné $${amount} de consolation !`);
    setShowRewardOption(false);
  };

  return (
    <div>
      {showRewardOption && (
        <div className="text-center p-6">
          <h2 className="text-xl mb-4">Vous avez perdu 😢</h2>
          <p className="mb-4">Regardez une pub pour gagner un bonus de consolation !</p>
          <RewardedAdButton 
            rewardAmount={2000}
            onRewardEarned={handleReward}
          />
        </div>
      )}
    </div>
  );
}
```

### 3. Boost quotidien

```tsx
// client/app/daily-bonus/page.tsx
import RewardedAdButton from '@/components/RewardedAdButton';

export default function DailyBonus() {
  const handleDailyBonus = async (amount: number) => {
    localStorage.setItem('lastDailyBonus', new Date().toISOString());
    // Ajouter le bonus
  };

  return (
    <div className="text-center p-6">
      <h1 className="text-2xl mb-4">💰 Bonus Quotidien</h1>
      <p className="mb-6">Regardez une pub pour recevoir votre bonus du jour !</p>
      <RewardedAdButton 
        rewardAmount={10000}
        onRewardEarned={handleDailyBonus}
      />
    </div>
  );
}
```

## Cooldown et Limites

### Cooldown par défaut
- **5 minutes** entre chaque pub récompensée
- Configurable dans `client/lib/ads.ts`:
  ```typescript
  const MIN_REWARDED_AD_INTERVAL = 300000; // 5 minutes en ms
  ```

### Fonctions utilitaires

```typescript
import { isRewardedAdReady, getRewardedAdCooldown } from '@/lib/ads';

// Vérifier si une pub est disponible
const isReady = await isRewardedAdReady(); // true/false

// Obtenir le temps restant en secondes
const cooldown = getRewardedAdCooldown(); // 0-300
```

## API Backend (Exemple)

Créez un endpoint pour créditer l'argent côté serveur:

```typescript
// server/src/routes/players.ts
app.post('/api/games/:gameId/players/:playerId/reward', async (req, res) => {
  const { gameId, playerId } = req.params;
  const { amount, source } = req.body;

  // Validation
  if (source !== 'rewarded_ad') {
    return res.status(400).json({ error: 'Invalid source' });
  }

  // Limiter le montant maximum
  if (amount > 10000) {
    return res.status(400).json({ error: 'Amount too high' });
  }

  // Vérifier le cooldown côté serveur (recommandé)
  const lastReward = await getLastRewardTime(playerId);
  if (Date.now() - lastReward < 300000) {
    return res.status(429).json({ error: 'Too soon' });
  }

  // Créditer le joueur
  await prisma.player.update({
    where: { id: playerId },
    data: { cash: { increment: amount } }
  });

  res.json({ success: true, newCash: player.cash + amount });
});
```

## Meilleures Pratiques

### 1. Sécurité
- ✅ Toujours valider côté serveur
- ✅ Limiter le montant maximum
- ✅ Vérifier le cooldown côté serveur
- ✅ Logger les récompenses pour détecter les abus

### 2. UX
- ✅ Indiquer clairement le montant de la récompense
- ✅ Afficher le temps restant avant la prochaine pub
- ✅ Donner un feedback immédiat après la récompense
- ✅ Ne pas forcer l'utilisateur à regarder des pubs

### 3. Monétisation
- 📊 Les pubs récompensées ont un **CPM plus élevé** (~2-5x)
- 💰 Équilibrez la récompense pour encourager sans dévaluer le jeu
- 🎯 Placez les boutons aux moments stratégiques

## Build et Test

### 1. Sync Capacitor
```powershell
cd mobile
npx cap sync
```

### 2. Build APK
```powershell
npx cap open android
# Dans Android Studio: Build → Build APK
```

### 3. Test sur appareil
- Installez l'APK sur un téléphone Android
- Cliquez sur le bouton de pub récompensée
- Regardez la pub en entier
- Vérifiez que la récompense est bien créditée

## Troubleshooting

### La pub ne s'affiche pas
1. Vérifiez que l'**Ad Unit ID** est correct
2. Utilisez l'**ID de test** en développement
3. Vérifiez les logs Android: `adb logcat | grep AdMob`
4. Attendez 5 minutes après la dernière pub

### La récompense n'est pas créditée
1. Vérifiez que le callback `onRewardEarned` est appelé
2. Vérifiez les logs de la console
3. Assurez-vous que l'utilisateur a regardé la pub EN ENTIER

### Erreur "Ad failed to load"
1. Vérifiez votre connexion internet
2. Vérifiez que le compte AdMob est actif
3. Attendez quelques heures après la création de l'Ad Unit

## Résumé des fichiers modifiés

✅ **Plugin natif Android**:
- `mobile/android/app/src/main/java/com/heritier/millionnaire/AdMobPlugin.java`

✅ **Bridge TypeScript**:
- `mobile/src/admob/index.ts`
- `mobile/src/admob/web.ts`

✅ **Client**:
- `client/lib/ads.ts`
- `client/components/RewardedAdButton.tsx` (nouveau)

## Next Steps

1. ✅ Créer l'Ad Unit ID dans AdMob
2. ✅ Remplacer l'ID de test par l'ID réel
3. ✅ Intégrer le bouton dans vos pages
4. ✅ Créer l'endpoint API pour créditer les récompenses
5. ✅ Build et test sur appareil réel
6. ✅ Monitorer les performances dans AdMob

---

**💡 Besoin d'aide ?** Consultez la [documentation AdMob officielle](https://developers.google.com/admob/android/rewarded)
