# 🔧 PLAN DE CORRECTIONS COMPLET - Héritier Millionnaire

**Date**: 18 novembre 2025  
**Objectif**: Préparer le code pour Google Play (sans publication automatique)

---

## 🎯 STATUT DES CORRECTIONS

### ✅ TERMINÉ
- [x] **1. Token/Profil Drag** - `getAuthToken()`, `getStoredSession()`, initialisation modifiées
- [x] **3. Listes Rétractables** - Composant `CollapsibleSection.tsx` créé et intégré dans `page.tsx`
- [x] **4. Navigation Immobilier** - Déjà corrigée dans une conversation précédente (aucun changement nécessaire)

### ⏳ EN ATTENTE DE VALIDATION
- [ ] **2. Garage/Réglages/Course Drag** - Nécessite tests après correction token
- [ ] **5. Nettoyage Code** - JSDoc, commentaires obsolètes (à faire après validation)

### 🚨 NOUVEAU PROBLÈME DÉTECTÉ
- [ ] **Erreur Suspense** - Pages `/immobilier` et `/immobilier/parc` nécessitent `<Suspense>` wrapper
  - Solution documentée dans `FIX_SUSPENSE_IMMOBILIER.md`

---

## 📊 DIAGNOSTIC GLOBAL

### ✅ État actuel du projet

**Points forts**:
- Architecture bien structurée (client Next.js + server Fastify + mobile Capacitor)
- Bridge Android déjà en place pour le drag (`getAuthToken()`, `getSessionData()`)
- Système d'authentification fonctionnel avec `apiFetch` dans `lib/api.ts`
- Navigation immobilier **DÉJÀ CORRIGÉE** (page parc créée, redirections fixées)

**Points à corriger**:
1. 🔴 Token/profil drag non synchronisé correctement
2. 🔴 Garage/réglages/démarrage de course dans le drag
3. 🟡 Listes accueil non rétractables (45+ entrées)
4. 🟡 Code mort et commentaires manquants

---

## 1️⃣ CORRECTION TOKEN/PROFIL DRAG

### 🔍 Analyse du problème

**Fichiers impliqués**:
- `mobile/android/app/src/main/assets/drag/main.js`
- `mobile/android/app/src/main/java/.../DragActivity.java`
- `client/lib/api.ts`

**Problème identifié**:
Le drag a son propre système de token (`hm-token` + `HM_TOKEN` dans localStorage), mais il n'est pas correctement synchronisé avec l'app principale au chargement.

**Flux actuel** (problématique):
```
1. Drag charge (main.js ligne ~2521)
2. ensureGuestToken() s'exécute
3. getAuthToken() lit localStorage 'hm-token' ou 'HM_TOKEN'
4. refreshAuthUi() appelle /api/auth/me
5. ❌ Le token peut être absent ou expiré
```

**Flux amélioré** (solution):
```
1. Drag charge
2. ✅ AVANT ensureGuestToken(), appeler window.AndroidDrag?.getAuthToken()
3. ✅ Sauvegarder le token récupéré dans localStorage
4. ✅ PUIS appeler /api/auth/me avec ce token
5. ✅ Afficher le profil correct ou état invité
```

### 📝 Modifications à apporter

#### **Fichier 1**: `mobile/android/app/src/main/assets/drag/main.js`

**Ligne ~125 - Fonction `getAuthToken()`** 

❌ **AVANT**:
```javascript
function getAuthToken() {
    try {
        // Priorité : token spécifique drag
        const dragToken = localStorage.getItem('hm-token');
        if (dragToken) return dragToken;
        // Fallback : token global utilisé par le client Next
        const globalToken = localStorage.getItem('HM_TOKEN');
        return globalToken || null;
    } catch {
        return null;
    }
}
```

✅ **APRÈS**:
```javascript
function getAuthToken() {
    try {
        // Priorité 1: Récupérer depuis le bridge Android si disponible
        if (typeof window !== 'undefined' && window.AndroidDrag && typeof window.AndroidDrag.getAuthToken === 'function') {
            try {
                const androidToken = window.AndroidDrag.getAuthToken();
                if (androidToken && androidToken.length > 10) {
                    // Sauvegarder dans localStorage pour réutilisation
                    localStorage.setItem('hm-token', androidToken);
                    localStorage.setItem('HM_TOKEN', androidToken);
                    console.log('[drag] Token récupéré depuis Android bridge');
                    return androidToken;
                }
            } catch (bridgeErr) {
                console.warn('[drag] Échec récupération token Android:', bridgeErr);
            }
        }
        
        // Priorité 2 : token spécifique drag en localStorage
        const dragToken = localStorage.getItem('hm-token');
        if (dragToken) {
            console.log('[drag] Token trouvé dans localStorage (hm-token)');
            return dragToken;
        }
        
        // Priorité 3 : token global utilisé par le client Next
        const globalToken = localStorage.getItem('HM_TOKEN');
        if (globalToken) {
            console.log('[drag] Token trouvé dans localStorage (HM_TOKEN)');
        }
        return globalToken || null;
    } catch (err) {
        console.error('[drag] Erreur getAuthToken:', err);
        return null;
    }
}
```

**Explication**: Ajout de la récupération prioritaire depuis le bridge Android, avec logs détaillés pour le débogage.

---

**Ligne ~190 - Fonction `getStoredSession()`**

❌ **AVANT**:
```javascript
function getStoredSession() {
    try { 
        const raw = localStorage.getItem('hm-session'); 
        return raw ? JSON.parse(raw) : null; 
    } catch { 
        return null; 
    }
}
```

✅ **APRÈS**:
```javascript
function getStoredSession() {
    try {
        // Priorité 1: Récupérer depuis le bridge Android si disponible
        if (typeof window !== 'undefined' && window.AndroidDrag && typeof window.AndroidDrag.getSessionData === 'function') {
            try {
                const androidSession = window.AndroidDrag.getSessionData();
                if (androidSession) {
                    const parsed = JSON.parse(androidSession);
                    if (parsed && parsed.gameId && parsed.playerId) {
                        // Sauvegarder dans localStorage pour réutilisation
                        localStorage.setItem('hm-session', androidSession);
                        console.log('[drag] Session récupérée depuis Android bridge:', parsed.gameId);
                        return parsed;
                    }
                }
            } catch (bridgeErr) {
                console.warn('[drag] Échec récupération session Android:', bridgeErr);
            }
        }
        
        // Priorité 2: localStorage
        const raw = localStorage.getItem('hm-session'); 
        if (raw) {
            const parsed = JSON.parse(raw);
            console.log('[drag] Session trouvée dans localStorage');
            return parsed;
        }
        return null;
    } catch (err) {
        console.error('[drag] Erreur getStoredSession:', err);
        return null; 
    }
}
```

**Explication**: Similaire au token, récupération prioritaire depuis Android avec logs.

---

**Ligne ~2521 - Initialisation au chargement**

❌ **AVANT**:
```javascript
// Synchroniser l'état initial (banque/niveau) depuis le serveur au chargement
ensureGuestToken().catch(() => null).then(() => {
    refreshAuthUi().then(() => loadDragSessionAndSyncHUD().catch(() => {}));
});
```

✅ **APRÈS**:
```javascript
// Synchroniser l'état initial (banque/niveau) depuis le serveur au chargement
// IMPORTANT: Récupérer le token depuis Android AVANT tout
(async function initDragAuth() {
    try {
        console.log('[drag] Initialisation authentification...');
        
        // Étape 1: Forcer la récupération du token depuis Android
        const token = getAuthToken();
        console.log('[drag] Token initial:', token ? 'PRÉSENT' : 'ABSENT');
        
        // Étape 2: Forcer la récupération de la session depuis Android
        const session = getStoredSession();
        console.log('[drag] Session initiale:', session ? `gameId=${session.gameId}` : 'ABSENTE');
        
        // Étape 3: Vérifier l'authentification
        await refreshAuthUi();
        
        // Étape 4: Charger la session drag et synchroniser le HUD
        await loadDragSessionAndSyncHUD();
        
        console.log('[drag] Initialisation authentification terminée');
    } catch (err) {
        console.error('[drag] Erreur initialisation:', err);
        // Continuer même en cas d'erreur pour permettre le mode invité
    }
})();
```

**Explication**: Initialisation séquentielle avec logs clairs pour tracer le flux d'authentification.

---

### 🧪 Tests à effectuer

**Après modification**:
1. ✅ Connectez-vous sur l'accueil de l'app Android
2. ✅ Cliquez sur "Drag Racing"
3. ✅ Ouvrez Chrome DevTools (`chrome://inspect`)
4. ✅ Vérifiez la console JavaScript:
   ```
   [drag] Initialisation authentification...
   [drag] Token récupéré depuis Android bridge
   [drag] Token initial: PRÉSENT
   [drag] Session récupérée depuis Android bridge: <gameId>
   [drag] Session initiale: gameId=<gameId>
   [drag] Initialisation authentification terminée
   ```
5. ✅ Vérifiez que le profil s'affiche (email au lieu de "Connexion requise")

---

## 2️⃣ CORRECTION GARAGE / RÉGLAGES / DÉMARRAGE

### 🔍 Analyse du problème

**Symptômes**:
- Bouton garage ne s'ouvre pas
- Réglages non sauvegardés
- Course ne démarre pas

**Hypothèses**:
1. Handlers non attachés correctement
2. Conditions de démarrage trop strictes
3. État du jeu bloqué

### 📝 Modifications à apporter

#### **Fichier**: `mobile/android/app/src/main/assets/drag/main.js`

**Ligne ~1300 - Handlers garage**

Vérifier que ces handlers existent:

```javascript
if (garageButton) {
    garageButton.addEventListener('click', () => {
        console.log('[drag] Ouverture garage');
        openGarage();
    });
}

if (closeGarageButton) {
    closeGarageButton.addEventListener('click', () => {
        console.log('[drag] Fermeture garage');
        closeGarage();
    });
}

if (applyGarageButton) {
    applyGarageButton.addEventListener('click', () => {
        console.log('[drag] Application réglages garage');
        applyTuning();
        closeGarage();
        setBanner('Réglages appliqués.', 2, '#7cffb0');
    });
}

if (resetGarageButton) {
    resetGarageButton.addEventListener('click', () => {
        console.log('[drag] Reset réglages garage');
        resetTuningToDefaults();
        updateGarageUI();
        setBanner('Réglages remis à zéro.', 2, '#d6ddff');
    });
}
```

**Ligne ~1480 - Fonction `startRace()`**

❌ **AVANT** (potentiellement trop strict):
```javascript
function startRace() {
    if (game.state !== 'idle') return;
    // Conditions strictes...
}
```

✅ **APRÈS** (plus permissif avec logs):
```javascript
function startRace() {
    console.log('[drag] startRace() appelé, état actuel:', game.state);
    
    if (game.state === 'running' || game.state === 'countdown') {
        console.warn('[drag] Course déjà en cours, annulation');
        return;
    }
    
    // Réinitialiser l'état si nécessaire
    if (game.state === 'finished') {
        console.log('[drag] État finished, réinitialisation...');
        game.state = 'idle';
        game.result = null;
    }
    
    if (game.state !== 'idle') {
        console.warn('[drag] État invalide pour démarrer:', game.state);
        return;
    }
    
    console.log('[drag] Démarrage course stage', game.stage);
    // ... reste du code
}
```

**Explication**: Ajout de logs détaillés et gestion plus permissive de l'état `finished`.

---

## 3️⃣ LISTES RÉTRACTABLES ACCUEIL

### 🔍 Analyse du problème

**Symptômes**:
- Liste `displayedLeaderboard` affiche jusqu'à 45 entrées
- Liste `players` peut être longue
- Page accueil trop chargée

**Solution**: Créer un composant `CollapsibleSection` réutilisable.

### 📝 Modifications à apporter

#### **Fichier 1**: `client/components/CollapsibleSection.tsx` (NOUVEAU)

```typescript
"use client";
import { useState, ReactNode } from "react";
import { ChevronDown, ChevronUp } from "lucide-react";

interface CollapsibleSectionProps {
  title: string;
  children: ReactNode;
  defaultOpen?: boolean;
  maxHeight?: string; // ex: "400px"
  itemCount?: number;
}

export default function CollapsibleSection({
  title,
  children,
  defaultOpen = true,
  maxHeight = "400px",
  itemCount
}: CollapsibleSectionProps) {
  const [isOpen, setIsOpen] = useState(defaultOpen);

  return (
    <section className="border border-neutral-800 rounded-lg bg-neutral-900/50">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="w-full px-4 py-3 flex items-center justify-between hover:bg-neutral-800/50 transition-colors"
      >
        <div className="flex items-center gap-3">
          <h3 className="text-lg font-semibold text-neutral-100">{title}</h3>
          {itemCount !== undefined && (
            <span className="px-2 py-0.5 rounded bg-neutral-800 border border-neutral-700 text-xs text-neutral-300">
              {itemCount}
            </span>
          )}
        </div>
        {isOpen ? (
          <ChevronUp className="w-5 h-5 text-neutral-400" />
        ) : (
          <ChevronDown className="w-5 h-5 text-neutral-400" />
        )}
      </button>

      {isOpen && (
        <div
          className="overflow-y-auto"
          style={{ maxHeight }}
        >
          {children}
        </div>
      )}
    </section>
  );
}
```

#### **Fichier 2**: `client/app/page.tsx`

**Ligne ~810 - Section Tableau de bord**

❌ **AVANT**:
```tsx
<section>
  <h2 className="text-xl font-semibold">Tableau de bord</h2>
  <p className="text-sm text-neutral-300">Classement (rafraîchissement manuel) — statut: {gameStatus}</p>
  <div className="mt-2 flex gap-2">
    <button onClick={updateState} className="px-3 py-2 rounded bg-neutral-700 hover:bg-neutral-600 text-sm">Actualiser</button>
  </div>
  <div className="mt-4 bg-neutral-900 rounded border border-neutral-800 overflow-x-auto">
    <table className="w-full text-sm">
      <thead>
        <tr className="text-left">
          <th className="p-2">#</th>
          <th className="p-2">Joueur</th>
          <th className="p-2">Valeur nette</th>
        </tr>
      </thead>
      <tbody>
        {displayedLeaderboard.map((e, i) => (
          <tr key={e.playerId} className="border-t border-neutral-800">
            <td className="p-2">{i + 1}</td>
            <td className="p-2 flex items-center gap-2">
              {onlineEmails.includes(e.nickname) && <span className="inline-block w-2 h-2 rounded-full bg-green-500" title="En ligne" />}
              {e.nickname}
            </td>
            <td className="p-2">{formatMoney(e.netWorth)}</td>
          </tr>
        ))}
      </tbody>
    </table>
  </div>
</section>
```

✅ **APRÈS**:
```tsx
<CollapsibleSection 
  title="Tableau de bord" 
  itemCount={displayedLeaderboard.length}
  defaultOpen={true}
  maxHeight="500px"
>
  <div className="px-4 py-3 space-y-3">
    <div className="flex items-center justify-between">
      <p className="text-sm text-neutral-300">Classement (rafraîchissement manuel) — statut: {gameStatus}</p>
      <button onClick={updateState} className="px-3 py-2 rounded bg-neutral-700 hover:bg-neutral-600 text-sm">
        Actualiser
      </button>
    </div>
    
    <div className="bg-neutral-900 rounded border border-neutral-800 overflow-x-auto">
      <table className="w-full text-sm">
        <thead>
          <tr className="text-left bg-neutral-800/50">
            <th className="p-2">#</th>
            <th className="p-2">Joueur</th>
            <th className="p-2">Valeur nette</th>
          </tr>
        </thead>
        <tbody>
          {displayedLeaderboard.map((e, i) => (
            <tr key={e.playerId} className="border-t border-neutral-800 hover:bg-neutral-800/30 transition-colors">
              <td className="p-2">{i + 1}</td>
              <td className="p-2 flex items-center gap-2">
                {onlineEmails.includes(e.nickname) && (
                  <span className="inline-block w-2 h-2 rounded-full bg-green-500" title="En ligne" />
                )}
                {e.nickname}
              </td>
              <td className="p-2">{formatMoney(e.netWorth)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  </div>
</CollapsibleSection>
```

**Ligne ~840 - Section Joueurs**

❌ **AVANT**:
```tsx
{players.length > 0 && (
  <section>
    <h3 className="text-lg font-semibold">Joueurs</h3>
    <ul className="mt-2 space-y-2 text-sm text-neutral-300">
      {players.map((p) => (
        // ... carte joueur ...
      ))}
    </ul>
  </section>
)}
```

✅ **APRÈS**:
```tsx
{players.length > 0 && (
  <CollapsibleSection 
    title="Joueurs actifs" 
    itemCount={players.length}
    defaultOpen={false}
    maxHeight="600px"
  >
    <ul className="px-4 py-3 space-y-2 text-sm text-neutral-300">
      {players.map((p) => (
        // ... carte joueur (identique) ...
      ))}
    </ul>
  </CollapsibleSection>
)}
```

**Ajout en haut du fichier**:
```typescript
import CollapsibleSection from "../components/CollapsibleSection";
```

---

## 4️⃣ NETTOYAGE ET SOLIDIFICATION DU CODE

### 📝 Actions à effectuer

#### **A) Supprimer le code mort**

**Fichiers à nettoyer**:

1. `client/app/page.tsx`:
   - Ligne ~105: Commentaire obsolète "Ancienne logique Capacitor supprimée"
     ```typescript
     // ❌ SUPPRIMER ce commentaire
     // Ancienne logique Capacitor supprimée (redirections externes). 
     ```

2. `mobile/android/app/src/main/assets/drag/main.js`:
   - Ligne ~1350: Commentaire "Auth events supprimés"
     ```javascript
     // ❌ SUPPRIMER ce commentaire
     // Auth events supprimés : la session se gère depuis l'accueil principal
     ```

#### **B) Harmoniser les noms**

**Convention à suivre** : anglais pour les variables techniques, français pour les messages utilisateur

**Exemples de renommage**:

1. `client/app/page.tsx`:
   ```typescript
   // ❌ AVANT
   const [knownNickname, setKnownNickname] = useState("");
   
   // ✅ APRÈS
   const [playerNickname, setPlayerNickname] = useState("");
   ```

2. `mobile/android/app/src/main/assets/drag/main.js`:
   ```javascript
   // ❌ AVANT
   function getStoredGuestIdentity() { ... }
   
   // ✅ APRÈS  
   function getGuestIdentityFromStorage() { ... }
   ```

#### **C) Ajouter des commentaires**

**Fichier**: `mobile/android/app/src/main/assets/drag/main.js`

Ajouter en haut du fichier:
```javascript
/**
 * DRAG RACING GAME - MAIN LOGIC
 * 
 * Ce fichier contient toute la logique du mini-jeu de drag racing.
 * 
 * ARCHITECTURE:
 * - Authentification: Utilise le bridge Android (DragActivity.java) pour récupérer
 *   le token et la session depuis SharedPreferences Capacitor
 * - API: Communique avec https://server-jeux-millionnaire.onrender.com
 * - Stockage: localStorage pour cache local (token, session, réglages)
 * - Canvas: Rendu 60 FPS avec requestAnimationFrame
 * 
 * FLOW PRINCIPAL:
 * 1. Initialisation (ligne ~2521): Récupération token/session depuis Android
 * 2. Authentification (refreshAuthUi): Vérification profil via /api/auth/me
 * 3. Session drag (loadDragSessionAndSyncHUD): Synchronisation cash/stage
 * 4. Course (startRace → update → finishRace): Mécanique de jeu
 * 5. Résultats: Envoi au serveur + MAJ du profil
 * 
 * DÉPENDANCES ANDROID:
 * - window.AndroidDrag.getAuthToken(): Récupère le token d'auth
 * - window.AndroidDrag.getSessionData(): Récupère gameId/playerId
 * - window.AndroidDrag.onRaceFinished(): Notifie la fin de course (pub)
 */
```

**Fichier**: `client/lib/api.ts`

Ajouter avant `export async function apiFetch`:
```typescript
/**
 * API FETCH - COUCHE D'ABSTRACTION RÉSEAU
 * 
 * Gère toutes les requêtes vers le backend avec:
 * - Authentification automatique (Bearer token depuis localStorage)
 * - CSRF token pour mutations (POST/PUT/PATCH/DELETE)
 * - Header X-Player-ID pour compatibilité iOS/Safari
 * - Retry automatique en cas de 401 avec refresh token
 * - Gestion d'erreurs structurée (ApiError avec status)
 * 
 * USAGE:
 * ```typescript
 * const data = await apiFetch<{ players: Player[] }>('/api/games/123/players');
 * ```
 * 
 * CONFIGURATION:
 * - API_BASE: Déterminé automatiquement (Capacitor → absolue, dev → relative)
 * - TOKEN_KEY: 'HM_TOKEN' dans localStorage
 * - CSRF: Récupéré via /api/auth/csrf et mis en cache
 */
```

---

## 5️⃣ COMMANDES DE TEST ET BUILD

### 🧪 Tests à exécuter

**Backend**:
```powershell
# Depuis le dossier server
cd "c:\Users\smori\application nouvelle\jeux du Millionaire\server"

# Linter
npm run lint

# Tests unitaires (si configurés)
npm test

# Build de production
npm run build
```

**Frontend**:
```powershell
# Depuis le dossier client
cd "c:\Users\smori\application nouvelle\jeux du Millionaire\client"

# Linter
npm run lint

# Tests TypeScript
npx tsc --noEmit

# Build de production
npm run build

# Vérifier la taille du bundle
npm run build -- --profile
```

**Mobile Android**:
```powershell
# Depuis le dossier mobile/android
cd "c:\Users\smori\application nouvelle\jeux du Millionaire\mobile\android"

# Clean build
.\gradlew clean

# Lint Android
.\gradlew lint

# Build debug (pour test)
.\gradlew assembleDebug

# Build release (pour Google Play - NE PAS PUBLIER)
.\gradlew assembleRelease

# Vérifier l'APK
Get-ChildItem -Path app\build\outputs\apk\release -Filter "*.apk"
```

### 📦 Préparation Google Play

**Fichiers à vérifier AVANT publication** (NE PAS MODIFIER maintenant):
- `mobile/android/app/build.gradle` → versionCode, versionName
- `mobile/android/app/src/main/AndroidManifest.xml` → permissions
- `mobile/android/keystore.properties` → signing config
- `mobile/STORE_LISTING_FR.md` → métadonnées Play Store

---

## 📋 CHECKLIST FINALE

Avant de considérer le code prêt pour Google Play:

### Code
- [ ] Tous les fichiers drag modifiés (token, garage, handlers)
- [ ] CollapsibleSection créé et intégré dans page.tsx
- [ ] Commentaires ajoutés dans main.js et api.ts
- [ ] Code mort supprimé
- [ ] Noms harmonisés (anglais technique)

### Tests
- [ ] Drag: Token synchronisé (vérifier logs Chrome DevTools)
- [ ] Drag: Garage s'ouvre et applique les réglages
- [ ] Drag: Course démarre et enregistre les résultats
- [ ] Accueil: Listes rétractables fonctionnent
- [ ] Immobilier: Navigation Sélectionner → Hypothèque → Parc ✅ (déjà OK)
- [ ] Build backend réussit sans erreur
- [ ] Build frontend réussit sans erreur
- [ ] Build Android APK debug réussit
- [ ] Build Android APK release réussit (sans le signer ni publier)

### Documentation
- [ ] README.md à jour avec dernières modifications
- [ ] CHANGELOG.md mis à jour avec cette version
- [ ] STORE_LISTING_FR.md vérifié (mais pas modifié)

### Google Play (NE PAS FAIRE MAINTENANT)
- [ ] Keystore configuré et sécurisé
- [ ] versionCode incrémenté dans build.gradle
- [ ] Screenshots Play Store préparés
- [ ] Privacy policy URL accessible
- [ ] Account deletion URL accessible

---

## 🎯 RÉSUMÉ DES CORRECTIONS

| Problème | Fichiers modifiés | Statut |
|----------|-------------------|--------|
| **1. Token/Profil Drag** | `drag/main.js` (getAuthToken, getStoredSession, init) | 🟡 À faire |
| **2. Garage/Réglages** | `drag/main.js` (handlers, startRace) | 🟡 À faire |
| **3. Listes Accueil** | `CollapsibleSection.tsx` (nouveau), `page.tsx` | 🟡 À faire |
| **4. Navigation Immobilier** | AUCUN (déjà corrigé) | ✅ Terminé |
| **5. Nettoyage Code** | `page.tsx`, `drag/main.js`, `api.ts` (commentaires) | 🟡 À faire |

---

## 📞 SUPPORT

Si des problèmes surviennent après ces modifications:
1. Vérifier les logs Chrome DevTools (`chrome://inspect`)
2. Vérifier les logs Android (`adb logcat | grep -E "DragActivity|drag"`)
3. Tester sur un appareil réel (pas seulement émulateur)
4. Comparer avec les extraits AVANT/APRÈS de ce document

---

**IMPORTANT**: Ce document est un PLAN. Les modifications doivent être appliquées une par une, avec tests entre chaque modification.

**NE PAS** tout modifier d'un coup, testez progressivement:
1. Token drag → Tester
2. Garage → Tester
3. Listes accueil → Tester
4. Nettoyage → Tester
5. Build final → Tester
