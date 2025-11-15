# Tutoriel Complet — Héritier Millionnaire (Novembre 2025)

Ce guide pas à pas explique toutes les fonctionnalités actuelles du jeu, les nouveautés récentes et la manière optimale de progresser. Il s'adresse à :
- Nouveau joueur (découverte rapide)
- Joueur confirmé (optimisation immobilier / bourse / quiz)
- Admin (maintenance, refill, génération IA des questions)

---
## 1. Objectif du jeu
Accumuler le patrimoine le plus élevé (cash + valeur des actifs + immobilier) dans une partie multijoueur en temps réel. Le jeu tourne en continu : une fois la partie passée de `lobby` à `running`, les actions économiques (achat, vente, annonces, quiz, pari) deviennent disponibles.

---
## 2. Vue d'ensemble des modules
| Module | Rôle | Gains potentiels | Fréquence d'action |
|--------|------|------------------|--------------------|
| Immobilier | Achat / location / gestion | Rentes de loyers | Quand vous avez du capital | 
| Bourse | Trading d'actifs simulés (SP500, QQQ, TSX, GLD, TLT) | Plus-value + dividendes | Souvent / opportunités |
| Portefeuille | Vue consolidée de vos positions | N/A | Consultation |
| Annonces (Listings) | P2P entre joueurs (revente biens) | Arbitrage | Occasionnel |
| Quiz | Répondre à 10 questions progressives (easy→medium→hard) | Cash immédiat sécurisé par paliers | Quand tokens dispo |
| Pari | Mini‑jeu de risque (selon implémentation actuelle) | Cash rapide (risqué) | Ponctuel |
| Présence | Indicateurs temps réel des joueurs connectés | Info sociale | Permanent |

---
## 3. Flux de démarrage
1. Accéder au client (ex: `http://localhost:3000` ou déploiement Vercel)
2. Créer ou rejoindre une partie (un code peut être utilisé)
3. Le serveur pose un cookie invité `HM_GUEST_ID` (identité persistante)
4. Le `gameId` et votre `playerId` sont enregistrés en `localStorage`
5. Interface principale (Dashboard) : navigation vers Immobilier / Bourse / Quiz / Pari.

Si vous perdez la session (gameId absent) : retourner à la page d'accueil et rejoindre à nouveau.

---
## 4. Immobilier
### 4.1 Types de biens
| Type | Seuil unités | Description |
|------|--------------|-------------|
| Maison | 1–1 | Entrée de gamme |
| Duplex | 2 | Deux logements |
| Triplex | 3 | Trois logements |
| Six‑plex | 6 | Petit immeuble locatif |
| Tour (50 log.) | ≥50 | Immeuble vertical |
| Gratte‑ciel (400 log.) | ≥400 | Très grand actif |
| Village futuriste (800+) | ≥800 | Actif emblématique |

Le loyer total = loyer unitaire × nombre de logements (affiché dans la fiche du bien).

### 4.2 Actions principales
- Acheter un bien disponible (stock banque)
- Vendre un bien (liquide le capital immobilisé)
- Refinancer (selon règles actuelles si exposées dans l'UI)

### 4.3 Refill (Nouveauté admin)
Pour assurer que la banque propose toujours certains paliers :
- `GET/POST /api/properties/refill/sixplex10` : garantit 10 six‑plex disponibles.
- `GET/POST /api/properties/refill/tower50x10` : garantit 10 tours de 50 logements.

(Bientôt : refill tours100 ->5 ; refill incrémental +10 ; affichage compte par type — fonctionnalités planifiées mais pas encore implémentées au moment de ce tutoriel.)

### 4.4 Stratégie rapide
- Début de partie : privilégier plusieurs six‑plex (bon ratio prix/loyers).
- Milieu : monter vers tour 50 pour effet d'échelle.
- Fin / capital élevé : viser gratte‑ciel + village futuriste pour maximiser la rente.

### 4.5 Vue filtrée
La page Immobilier dispose de filtres par type (boutons) et d'une zone récap des messages (succès / erreurs / refills).

---
## 5. Bourse
### 5.1 Actifs disponibles (réduction volontaire pour performance)
- SP500
- QQQ
- TSX
- GLD (Or)
- TLT (Obligations long terme)

### 5.2 Données marché
- Derniers prix (endpoint `markets/latest`) — cache mémoire ≈ 90s
- Rendements agrégés (endpoint `markets/returns?window=1d|7d|30d`)
- Dividendes versés trimestriellement aux détenteurs éligibles

### 5.3 Trading
Acheter / vendre modifie votre portefeuille. Les événements sont diffusés en temps réel (Socket.IO) pour que les autres joueurs voient l'évolution.

### 5.4 Stratégie
- Diversifier tôt pour lisser la variance
- Surveiller les dividendes (actifs à rendement vs croissance)
- Profiter du cache: ajouter `?debug=1` pour forcer un rafraîchissement côté admin / test.

---
## 6. Portefeuille
Vue consolidée des positions boursières et immobilières (selon pages implémentées). Permet d'évaluer rendement global. Utiliser avant de prendre une grosse décision (vente massive ou achat majeur).

---
## 7. Quiz Millionnaire
### 7.1 Objectif
Gagner du cash rapide via connaissances générales / spéciales (catégorie Anatomy ajoutée) sur une série de 10 questions à difficulté croissante.

### 7.2 Difficulté progressive (Mise à jour Nov 2025)
| Question # | Difficulté | Description |
|------------|------------|-------------|
| 1–2 | Facile (Enfants) | Questions simples/kid-friendly |
| 3–5 | Moyenne | Culture générale, économie, sciences |
| 6–10 | Difficile (Général) | Multi‑catégories incluant anatomy/biologie |

Fin de la session : gains sécurisés selon votre progression (paliers). Un abandon ou erreur avant un palier sécurisé peut réduire vos gains.

### 7.3 Tokens
- Chaque joueur accumule des tokens avec le temps (1 de base + regen horaire)
- Un token est consommé pour démarrer une session quiz
- Endpoint status: `/api/games/:id/quiz/status`

### 7.4 Génération IA des questions
- Service d'IA (OpenAI) génère des lots par catégorie/difficulté
- Catégorie récente: `anatomy` (biologie du corps humain, forces/faiblesses, organes, physiologie)
- Fallback statique activé si clé API absente pour garantir un minimum de stock

### 7.5 Sélection des questions
- Évite les doublons vus par le joueur (marquage seen)
- Parcourt le pool selon la difficulté cible (easy / medium / hard generique) sans biais spécifique (logique/QI retiré)

### 7.6 Conseils
- Lire attentivement avant de répondre (pas de retour arrière)
- Utiliser vos premiers tokens pour comprendre la courbe de difficulté
- Quitter stratégiquement après un palier sécurisé si vous n'êtes pas sûr pour la prochaine question difficile

### 7.7 Dépannage
Consulter `TROUBLESHOOTING_QUIZ.md` pour les erreurs courantes (tokens, absence de questions, CORS, session).

---
## 8. Pari (module risk)
Fonctionnalité de pari (selon version en cours) permettant de miser une somme pour un rendement incertain. Utilisez avec prudence : ce n'est pas un canal fiable de croissance à long terme, mais un outil tactique.

---
## 9. Annonces (Listings P2P)
- Créer une annonce pour vendre un bien (`POST /listings`)
- Annuler (`POST /listings/:id/cancel`)
- Accepter (`POST /listings/:id/accept`)

Utilisation stratégique : revendre un actif à un prix supérieur à sa valeur de base si la demande est forte. Surveiller la latence du marché et la disponibilité des refills côté banque.

---
## 10. Présence & Temps Réel
- Socket global pour rejoindre un canal de partie (presence, events)
- Diffusion d'événements: achats, ventes, annonces, quiz démarré (selon instrumentation)

Astuce: La visibilité des autres joueurs aide à anticiper pénuries sur certains actifs.

---
## 11. Administration & Maintenance
| Action | Outil / Endpoint | Notes |
|--------|------------------|-------|
| Refill six‑plex | `/api/properties/refill/sixplex10` | GET ou POST |
| Refill tours 50 | `/api/properties/refill/tower50x10` | GET ou POST |
| Replenish générique | `/api/properties/replenish` | Remplit banque selon logique server |
| Purge/Replenish quiz | Script `server/scripts/quiz_purge_and_replenish.ts` | Nettoie duplicats + replenish |
| Génération questions IA | Cron + endpoints internes | Voir `aiQuestions.ts` |
| Désactivation pubs (rewarded) | Stubs côté client/serveur | Déjà appliqué (nov 2025) |

Fonctions planifiées (non encore actives) : refill tours100 ->5 ; incrémental +10 ; UI compte par type.

### 11.1 Sécurité CORS
- Variable `CLIENT_ORIGIN` doit contenir domaines autorisés (localhost, vercel.app, mobile `capacitor://localhost` si appli).

### 11.2 Cache Marché
- TTL ~90s ; utiliser `?debug=1` pour bypass lors de tests admin.

### 11.3 Dividendes
- Versés trimestriellement automatiquement via cron (dernier jour ouvrable des mois 3/6/9/12).

---
## 12. Mobile & PWA
- Application web installable (manifest + service worker)
- Wrapper Capacitor disponible dans `mobile/` pour Android (ajouter origin mobile à CORS)

---
## 13. Stratégies Globales
### Début
- Accumuler loyers rapides via 6‑plex
- Lancer quelques sessions quiz pour capitaliser sur paliers faciles/moyens

### Milieu
- Diversifier portefeuille bourse (éviter concentration unique)
- Passer progressivement vers tours 50 pour effet d'échelle

### Fin
- Investir dans mega‑structures (gratte‑ciel, village futuriste)
- Utiliser quiz difficile (Q6–10) pour gros boosts ponctuels
- Arbitrer via annonces si prix marché interne augmente

### Risques à surveiller
- Sur‑exposition à un seul actif boursier (volatilité)
- Mauvaise gestion tokens quiz (laisser stagner = manque de cash rapide)
- Oublier de sécuriser un palier et tout perdre sur une mauvaise réponse tardive

---
## 14. FAQ Rapide
| Question | Réponse |
|----------|---------|
| Je n'ai pas de token quiz | Attendre l'accumulation horaire ou seed admin |
| Questions répétées | Le système marque comme "seen"; possible purge si pool trop réduit |
| Pas de six‑plex dispo | Admin utilise refill sixplex10 |
| Page blanche quiz | Voir guide dépannage (console + status endpoint) |
| Gains faibles | Diversifiez + quiz + passer à biens de niveau supérieur |

---
## 15. Prochaines évolutions (Roadmap courte)
- Refill tours 100 (cible 5) + incrémental ±10
- UI compte par type (inventaire banque en temps réel)
- Amélioration pari (plusieurs modes de risque / multiplicateurs)
- Dashboard stratégique consolidé (patrimoine net, rentabilité horaire)
- Plus de catégories quiz (économie avancée, technologies propres)

---
## 16. Résumé express
1. Rejoignez une partie (cookie invité attribué)
2. Achetez 1–2 six‑plex
3. Diversifiez bourse (2 actifs min.)
4. Lancez un quiz (token) : sécurisez paliers
5. Reinvestissez le cash en tour 50
6. Visez structures >400 unités en late game
7. Surveillez refills & annonces pour opportunités d'arbitrage

Bon jeu et bonne accumulation de patrimoine ! 🎉

---
*Dernière mise à jour : 8 novembre 2025*
