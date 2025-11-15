-- Script de redémarrage manuel de la partie
-- À exécuter sur Render: Dashboard > Service > Shell > psql $DATABASE_URL

-- 1. Identifier l'ID de la partie (remplacer par le bon ID si différent)
-- SELECT id, code, status FROM "Game";

-- 2. Définir l'ID de la partie à redémarrer
-- Remplacer 'cmhj4yjta0000f0isofn3itjn' par l'ID réel de ta partie
\set gameId 'cmhj4yjta0000f0isofn3itjn'

-- 3. Commencer la transaction
BEGIN;

-- 4. Supprimer les données dans l'ordre (pour éviter les violations de clés étrangères)
DELETE FROM "Listing" WHERE "gameId" = :'gameId';
DELETE FROM "DividendLog" WHERE "gameId" = :'gameId';
DELETE FROM "RepairEvent" WHERE "holdingId" IN (SELECT id FROM "PropertyHolding" WHERE "gameId" = :'gameId');
DELETE FROM "RefinanceLog" WHERE "holdingId" IN (SELECT id FROM "PropertyHolding" WHERE "gameId" = :'gameId');
DELETE FROM "PropertyHolding" WHERE "gameId" = :'gameId';
DELETE FROM "MarketHolding" WHERE "gameId" = :'gameId';
DELETE FROM "MarketTick" WHERE "gameId" = :'gameId';
DELETE FROM "Player" WHERE "gameId" = :'gameId';

-- 5. Réinitialiser le statut de la partie
UPDATE "Game" SET "status" = 'running', "startedAt" = NOW() WHERE id = :'gameId';

-- 6. Valider la transaction
COMMIT;

-- 7. Vérifier le résultat
SELECT id, code, status, "startedAt" FROM "Game" WHERE id = :'gameId';
SELECT COUNT(*) as player_count FROM "Player" WHERE "gameId" = :'gameId';
SELECT COUNT(*) as tick_count FROM "MarketTick" WHERE "gameId" = :'gameId';
