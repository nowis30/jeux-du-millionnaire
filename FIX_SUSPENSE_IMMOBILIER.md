# 🔧 Correction Erreur Suspense - Pages Immobilier

## ❌ Erreur
```
⨯ useSearchParams() should be wrapped in a suspense boundary at page "/immobilier"
⨯ useSearchParams() should be wrapped in a suspense boundary at page "/immobilier/parc"
```

## 📋 Cause
Les pages `/immobilier/page.tsx` et `/immobilier/parc/page.tsx` utilisent `useSearchParams()` sans l'envelopper dans un composant `<Suspense>`. Next.js 14+ requiert cette enveloppe pour permettre le rendu côté serveur (SSR) et l'export statique.

---

## ✅ Solution 1: Wrapper dans Suspense (RECOMMANDÉ)

### Fichier: `client/app/immobilier/page.tsx`

**AVANT**:
```typescript
'use client';
import { useSearchParams } from 'next/navigation';

export default function ImmobilierRouter() {
  const searchParams = useSearchParams();
  const select = searchParams?.get('select');
  
  // ... reste du code
}
```

**APRÈS**:
```typescript
'use client';
import { Suspense } from 'react';
import { useSearchParams } from 'next/navigation';

function ImmobilierRouterContent() {
  const searchParams = useSearchParams();
  const select = searchParams?.get('select');
  
  // ... reste du code inchangé
}

export default function ImmobilierRouter() {
  return (
    <Suspense fallback={<div className="flex items-center justify-center min-h-screen">
      <div className="text-white">Chargement...</div>
    </div>}>
      <ImmobilierRouterContent />
    </Suspense>
  );
}
```

### Fichier: `client/app/immobilier/parc/page.tsx`

**AVANT**:
```typescript
'use client';
import { useSearchParams } from 'next/navigation';

export default function ParcImmobilier() {
  const searchParams = useSearchParams();
  const select = searchParams?.get('select');
  
  // ... reste du code
}
```

**APRÈS**:
```typescript
'use client';
import { Suspense } from 'react';
import { useSearchParams } from 'next/navigation';

function ParcImmobilierContent() {
  const searchParams = useSearchParams();
  const select = searchParams?.get('select');
  
  // ... reste du code inchangé
}

export default function ParcImmobilier() {
  return (
    <Suspense fallback={<div className="flex items-center justify-center min-h-screen bg-neutral-950">
      <div className="text-white text-lg">Chargement du parc immobilier...</div>
    </div>}>
      <ParcImmobilierContent />
    </Suspense>
  );
}
```

---

## ✅ Solution 2: Utiliser router.query au lieu de useSearchParams

### Alternative si Suspense pose problème

```typescript
'use client';
import { useEffect, useState } from 'react';

export default function ImmobilierRouter() {
  const [select, setSelect] = useState<string | null>(null);
  
  useEffect(() => {
    // Récupérer les query params côté client uniquement
    const params = new URLSearchParams(window.location.search);
    setSelect(params.get('select'));
  }, []);
  
  // ... reste du code avec `select`
}
```

**Avantages**: Pas de Suspense boundary nécessaire  
**Inconvénients**: Léger délai avant affichage (attente useEffect)

---

## 🎯 Recommandation

**Utiliser Solution 1 (Suspense)** car :
- Plus "Next.js-friendly"
- Meilleure expérience utilisateur (affichage immédiat)
- Prépare l'app pour le SSR futur
- Conforme aux bonnes pratiques Next.js 14+

---

## 🔨 Commandes après correction

```powershell
# Rebuild client
cd "c:\Users\smori\application nouvelle\jeux du Millionaire\client"
npm run build

# Vérifier qu'aucune erreur n'apparaît
# Les lignes "✓ Generating static pages (29/29)" doivent s'afficher sans erreur
```

---

## 📚 Ressources

- [Next.js - Missing Suspense Boundary](https://nextjs.org/docs/messages/missing-suspense-with-csr-bailout)
- [React Suspense Documentation](https://react.dev/reference/react/Suspense)
- [useSearchParams Best Practices](https://nextjs.org/docs/app/api-reference/functions/use-search-params)
