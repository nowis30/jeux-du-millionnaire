# Guide de configuration AdMob en production

Ce guide explique comment créer des IDs de publicité AdMob de production et les intégrer dans l'application Android.

## ⚠️ Important

- **Ne PAS** utiliser les IDs de test en production
- Les IDs de test sont pour le développement uniquement
- Utiliser vos propres IDs en production pour recevoir les revenus publicitaires

## Étape 1 : Créer un compte AdMob

1. Allez sur [https://admob.google.com](https://admob.google.com)
2. Connectez-vous avec votre compte Google
3. Acceptez les conditions d'utilisation

## Étape 2 : Créer une application Android

1. Dans le tableau de bord AdMob, cliquez sur **"Applications"** dans le menu
2. Cliquez sur **"Ajouter une application"**
3. Sélectionnez **"Android"** comme plateforme
4. Répondez **"Non"** si l'application n'est pas encore sur Google Play (vous pouvez la mettre à jour plus tard)
5. Entrez le nom de l'application : **"Héritier Millionnaire"**
6. Cliquez sur **"Ajouter"**
7. Notez l'**ID de l'application** (format : `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`)

⚠️ **Important** : L'ID de l'application n'est PAS utilisé directement dans le code, mais vous en aurez besoin pour créer les unités publicitaires.

## Étape 3 : Créer les unités publicitaires

Vous devez créer **2 unités publicitaires** :

### A. Annonce Interstitielle (plein écran)

1. Dans l'application que vous venez de créer, cliquez sur **"Unités d'annonces"**
2. Cliquez sur **"Ajouter une unité d'annonces"**
3. Sélectionnez **"Interstitielle"**
4. Nommez l'unité : **"Interstitial"** ou **"Pub plein écran"**
5. Cliquez sur **"Créer une unité d'annonces"**
6. **Copiez l'ID d'unité publicitaire** (format : `ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY`)
   - Cet ID sera utilisé pour remplacer la ligne 31 dans `AdMobPlugin.java`

### B. Annonce Récompensée (vidéo avec bonus)

1. Cliquez à nouveau sur **"Ajouter une unité d'annonces"**
2. Sélectionnez **"Annonce récompensée"**
3. Nommez l'unité : **"Rewarded"** ou **"Pub bonus"**
4. Configurez la récompense :
   - Nom de la récompense : **"Bonus"**
   - Valeur : **1** (nous gérons le montant côté serveur)
5. Cliquez sur **"Créer une unité d'annonces"**
6. **Copiez l'ID d'unité publicitaire** (format : `ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ`)
   - Cet ID sera utilisé pour remplacer la ligne 35 dans `AdMobPlugin.java`

## Étape 4 : Intégrer les IDs dans le code

Ouvrez le fichier suivant :
```
mobile/android/app/src/main/java/com/heritier/millionnaire/AdMobPlugin.java
```

### Ligne 31 - ID Interstitielle (INTERSTITIAL_AD_UNIT_ID)

**Remplacez :**
```java
private static final String INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-3940256099942544/1033173712"; // Test ID
```

**Par :**
```java
private static final String INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-VOTRE_ID_INTERSTITIELLE/XXXXXXXXXX";
```

### Ligne 35 - ID Récompensée (REWARDED_AD_UNIT_ID)

**Remplacez :**
```java
private static final String REWARDED_AD_UNIT_ID = "ca-app-pub-3940256099942544/5224354917"; // Test ID
```

**Par :**
```java
private static final String REWARDED_AD_UNIT_ID = "ca-app-pub-VOTRE_ID_RECOMPENSE/YYYYYYYYYY";
```

## Étape 5 : Reconstruire l'application

Après avoir modifié les IDs :

1. Ouvrez un terminal PowerShell
2. Naviguez vers le dossier `mobile`
3. Exécutez la commande de build :

```powershell
cd mobile
.\gradlew assembleRelease
```

Ou utilisez Android Studio pour rebuilder le projet.

## Étape 6 : Vérifier l'intégration

Après déploiement :

1. Ouvrez AdMob et allez dans votre application
2. Sous **"Aperçu"**, vous devriez voir des impressions et des clics après quelques heures
3. Les revenus commenceront à s'afficher dans **"Paiements"** après validation

⚠️ **Délai de traitement** : Il peut y avoir un délai de 24-48h avant que les premières statistiques apparaissent dans AdMob.

## Résumé des IDs

| Type | Emplacement dans le code | Format d'exemple |
|------|--------------------------|------------------|
| **Interstitielle** | `AdMobPlugin.java:31` | `ca-app-pub-1234567890123456/0987654321` |
| **Récompensée** | `AdMobPlugin.java:35` | `ca-app-pub-1234567890123456/1234567890` |

## Conformité RGPD

L'application intègre déjà un bandeau de consentement RGPD :
- Le bandeau s'affiche au premier lancement
- Le consentement est sauvegardé dans `localStorage`
- AdMob ne s'initialise que si l'utilisateur a accepté
- Lien vers la politique de confidentialité : `/confidentialite/`

---

## 🔍 Troubleshooting

### Les pubs ne s'affichent pas

1. Vérifiez que vous utilisez les bons IDs (pas les IDs de test)
2. Attendez 24-48h après la création des unités publicitaires
3. Vérifiez que l'utilisateur a accepté le consentement RGPD
4. Vérifiez les logs Android avec : `adb logcat | grep -i "AdMob"`

### Erreur "Ad failed to load"

- Vérifiez que les IDs sont corrects (pas d'espace, bon format)
- Vérifiez que l'application est connectée à Internet
- Sur un nouvel appareil, les premières pubs peuvent prendre du temps

### Revenus à 0

- Il faut un certain volume d'impressions pour générer des revenus
- Les revenus dépendent de la géographie, du contenu, et de l'engagement
- Consultez les rapports dans AdMob pour voir les détails

---

**Date de création** : 2025  
**Dernière mise à jour** : 2025
