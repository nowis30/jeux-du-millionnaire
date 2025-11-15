# Script PowerShell pour redémarrer la partie via l'API PostgreSQL directe
# Nécessite: connexion à la base de données PostgreSQL

param(
    [string]$GameId = "cmhj4yjta0000f0isofn3itjn",
    [string]$DatabaseUrl = $env:DATABASE_URL
)

if ([string]::IsNullOrEmpty($DatabaseUrl)) {
    Write-Host "❌ DATABASE_URL non définie. Passe-la en paramètre:" -ForegroundColor Red
    Write-Host '.\scripts\manual-restart-db.ps1 -DatabaseUrl "postgresql://user:pass@host:port/db"' -ForegroundColor Yellow
    exit 1
}

Write-Host "=== Redémarrage manuel de la partie ===" -ForegroundColor Cyan
Write-Host "Game ID: $GameId" -ForegroundColor Yellow
Write-Host ""

# Commandes SQL
$sql = @"
BEGIN;
DELETE FROM "Listing" WHERE "gameId" = '$GameId';
DELETE FROM "DividendLog" WHERE "gameId" = '$GameId';
DELETE FROM "RepairEvent" WHERE "holdingId" IN (SELECT id FROM "PropertyHolding" WHERE "gameId" = '$GameId');
DELETE FROM "RefinanceLog" WHERE "holdingId" IN (SELECT id FROM "PropertyHolding" WHERE "gameId" = '$GameId');
DELETE FROM "PropertyHolding" WHERE "gameId" = '$GameId';
DELETE FROM "MarketHolding" WHERE "gameId" = '$GameId';
DELETE FROM "MarketTick" WHERE "gameId" = '$GameId';
DELETE FROM "Player" WHERE "gameId" = '$GameId';
UPDATE "Game" SET "status" = 'running', "startedAt" = NOW() WHERE id = '$GameId';
COMMIT;
"@

try {
    # Exécuter via psql (nécessite PostgreSQL client installé)
    $sql | psql $DatabaseUrl
    
    Write-Host "✅ Partie redémarrée avec succès!" -ForegroundColor Green
    
    # Vérifier
    $checkSql = "SELECT COUNT(*) as player_count FROM ""Player"" WHERE ""gameId"" = '$GameId';"
    Write-Host "`nVérification:" -ForegroundColor Yellow
    $checkSql | psql $DatabaseUrl
}
catch {
    Write-Host "❌ Erreur:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}
