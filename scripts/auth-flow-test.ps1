param(
  [Parameter(Mandatory=$true)] [string]$ApiBase,
  [Parameter(Mandatory=$true)] [string]$Email,
  [Parameter(Mandatory=$true)] [string]$Password,
  [Parameter(Mandatory=$false)] [string]$AdminSecret
)

# Test complet: register -> (optionnel: verify via admin) -> login -> csrf -> get games -> join
# Exemples:
# ./scripts/auth-flow-test.ps1 -ApiBase "https://server-jeux-millionnaire.onrender.com" -Email "test+123@example.com" -Password "Passw0rd!" -AdminSecret "<secret>"

$ErrorActionPreference = 'Stop'
$ApiBase = $ApiBase.TrimEnd('/')

function Show-HttpError($context, $err) {
  Write-Host "[$context]" -ForegroundColor Yellow
  if ($err.Exception -and $err.Exception.Response) {
    try {
      $status = [int]$err.Exception.Response.StatusCode
      Write-Host "HTTP $status" -ForegroundColor Red
      $stream = $err.Exception.Response.GetResponseStream()
      $reader = New-Object System.IO.StreamReader($stream)
      $text = $reader.ReadToEnd()
      if ($text) { Write-Host $text }
    } catch {
      Write-Host $err -ForegroundColor Red
    }
  } else {
    Write-Host $err -ForegroundColor Red
  }
}

# Session pour gérer les cookies hm_auth / hm_csrf
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

# 1) Register
try {
  Write-Host "[1/6] Register $Email" -ForegroundColor Cyan
  $registerBody = @{ email = $Email; password = $Password } | ConvertTo-Json
  $reg = Invoke-RestMethod -Method Post -Uri "$ApiBase/api/auth/register" -WebSession $session -Body $registerBody -ContentType 'application/json'
  Write-Host "Register: $(($reg | ConvertTo-Json -Depth 5))" -ForegroundColor Green
} catch {
  # 409 attendu si l'email existe déjà
  if ($_.Exception.Response -and [int]$_.Exception.Response.StatusCode -eq 409) {
    Write-Host "Email déjà utilisé (409) — on continue avec login" -ForegroundColor Yellow
  } else {
    Show-HttpError "register" $_
    exit 1
  }
}

# 2) Vérification admin (optionnel)
if ($AdminSecret) {
  try {
    Write-Host "[2/6] Admin verify $Email" -ForegroundColor Cyan
    $base = "$ApiBase/api/auth/admin/verify-user"
    $ub = New-Object System.UriBuilder($base)
    $qs = [System.Web.HttpUtility]::ParseQueryString([string]::Empty)
    $qs["email"] = $Email
    $qs["secret"] = $AdminSecret
    $ub.Query = $qs.ToString()
    $verifyUrl = $ub.Uri.AbsoluteUri
    $ver = Invoke-RestMethod -Method Get -Uri $verifyUrl -WebSession $session
    Write-Host "Admin verify: $(($ver | ConvertTo-Json -Depth 5))" -ForegroundColor Green
  } catch {
    Show-HttpError "admin-verify" $_
    # on tente quand même le login
  }
}

# 3) Login
$token = $null
try {
  Write-Host "[3/6] Login $Email" -ForegroundColor Cyan
  $loginBody = @{ email = $Email; password = $Password } | ConvertTo-Json
  $log = Invoke-RestMethod -Method Post -Uri "$ApiBase/api/auth/login" -WebSession $session -Body $loginBody -ContentType 'application/json'
  $token = $log.token
  if (-not $token) { throw "Pas de token dans la réponse de login" }
  Write-Host "Login OK, token présent (12h)." -ForegroundColor Green
} catch {
  if ($_.Exception.Response -and [int]$_.Exception.Response.StatusCode -eq 403) {
    Write-Host "403: Email non vérifié. Cliquez le lien reçu par email ou relancez avec -AdminSecret pour valider." -ForegroundColor Yellow
  } else {
    Show-HttpError "login" $_
  }
  exit 1
}

# 4) CSRF (pour méthodes POST)
$csrf = $null
try {
  Write-Host "[4/6] Fetch CSRF" -ForegroundColor Cyan
  $csrfRes = Invoke-RestMethod -Method Get -Uri "$ApiBase/api/auth/csrf" -WebSession $session
  $csrf = $csrfRes.csrf
  if (-not $csrf) { Write-Host "CSRF manquant, on tentera la tolérance côté serveur." -ForegroundColor Yellow }
} catch {
  Write-Host "CSRF non récupéré (tolérance possible si Authorization Bearer présent)." -ForegroundColor Yellow
}

# 5) Récupérer la partie globale
$gameId = $null
try {
  Write-Host "[5/6] GET /api/games" -ForegroundColor Cyan
  $games = Invoke-RestMethod -Method Get -Uri "$ApiBase/api/games" -WebSession $session
  $gameId = $games.games[0].id
  if (-not $gameId) { throw "Aucune partie retournée" }
  Write-Host "Game: $($games.games[0].code) / $gameId" -ForegroundColor Green
} catch {
  Show-HttpError "games" $_
  exit 1
}

# 6) Join
try {
  Write-Host "[6/6] POST /api/games/$gameId/join" -ForegroundColor Cyan
  $headers = @{ Authorization = "Bearer $token" }
  if ($csrf) { $headers['x-csrf-token'] = $csrf }
  $join = Invoke-RestMethod -Method Post -Uri "$ApiBase/api/games/$gameId/join" -WebSession $session -Headers $headers -ContentType 'application/json' -Body '{}' 
  Write-Host ("Join OK -> playerId: {0}" -f $join.playerId) -ForegroundColor Green
  $join | ConvertTo-Json -Depth 6
} catch {
  Show-HttpError "join" $_
  exit 1
}
