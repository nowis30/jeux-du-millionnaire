param(
    [Parameter(Mandatory=$true)] [string]$ApiBase,
    [Parameter(Mandatory=$true)] [string]$GameId,
    [Parameter(Mandatory=$true)] [string]$BearerToken
)

# Exemples d'usage (PowerShell):
# ./scripts/admin-restart.ps1 -ApiBase "https://server-jeux-millionnaire.onrender.com" -GameId "<id>" -BearerToken "eyJhbGciOiJIUzI1NiIs..."

$ErrorActionPreference = 'Stop'

$restartUrl = ($ApiBase.TrimEnd('/')) + "/api/games/$GameId/restart"

$headers = @{
  "Authorization" = "Bearer $BearerToken"
  # La plupart des clients envoient un header anti-CSRF; le serveur le tolère.
  "X-CSRF" = "1"
}

$body = @{ confirm = $true } | ConvertTo-Json

try {
  Write-Host "POST $restartUrl" -ForegroundColor Cyan
  $resp = Invoke-RestMethod -Method Post -Uri $restartUrl -Headers $headers -Body $body -ContentType 'application/json'
  Write-Host "Redémarrage déclenché avec succès." -ForegroundColor Green
  $resp | ConvertTo-Json -Depth 6
} catch {
  if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
    $status = [int]$_.Exception.Response.StatusCode
    Write-Host "Erreur HTTP $status" -ForegroundColor Red
    try {
      $stream = $_.Exception.Response.GetResponseStream()
      $reader = New-Object System.IO.StreamReader($stream)
      $text = $reader.ReadToEnd()
      if ($text) { Write-Host $text }
    } catch {}
  } else {
    Write-Host $_ -ForegroundColor Red
  }
  exit 1
}
