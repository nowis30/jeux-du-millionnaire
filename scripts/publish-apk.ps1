param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$ApkPath,

  [Parameter(Mandatory = $true, Position = 1)]
  [string]$Tag,

  [Parameter(Mandatory = $true, Position = 2)]
  [string]$ReleaseName,

  [Parameter(Mandatory = $false, Position = 3)]
  [string]$NotesFile,

  [Parameter(Mandatory = $false)]
  [string]$Repo = "nowis30/jeux-millionnaire-APK"
)

<#
.SYNOPSIS
  Publie automatiquement un APK sur une release GitHub.

.DESCRIPTION
  * Valide la présence de l'APK et sa taille (< 2 Go, limite GitHub).
  * Crée ou met à jour une release sur le dépôt cible via GitHub CLI.
  * Ajoute l'APK en tant qu'asset unique.

.PREREQUIS
  - GitHub CLI (`gh`) installé : https://cli.github.com/
  - Authentification `gh auth login` déjà effectuée avec accès écriture au dépôt cible.

.EXAMPLE
  ./publish-apk.ps1 -ApkPath "mobile/android/app/build/outputs/apk/release/app-release.apk" -Tag "v1.0.3" -ReleaseName "Héritier Millionnaire v1.0.3"

.EXAMPLE
  ./publish-apk.ps1 -ApkPath "C:/temp/hm.apk" -Tag "v1.0.3" -ReleaseName "Héritier Millionnaire v1.0.3" -NotesFile "notes.md" -Repo "nowis30/jeux-millionnaire-APK"
#>

function Fail($message) {
  Write-Error $message
  exit 1
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  Fail "GitHub CLI (gh) introuvable. Installez-le depuis https://cli.github.com/ et relancez."
}

if (-not (Test-Path $ApkPath)) {
  Fail "Fichier APK introuvable : $ApkPath"
}

$apk = Get-Item $ApkPath
if ($apk.Length -ge 2GB) {
  Fail ("L'APK dépasse la limite GitHub (2 Go). Taille actuelle : {0:N2} Go" -f ($apk.Length / 1GB))
}

$notesArguments = @()
if ($NotesFile) {
  if (-not (Test-Path $NotesFile)) {
    Fail "Fichier de notes introuvable : $NotesFile"
  }
  $notesArguments = @('--notes-file', (Resolve-Path $NotesFile))
} else {
  $defaultNotes = "Version publiée le $(Get-Date -Format 'yyyy-MM-dd HH:mm') via script."
  $notesTemp = New-TemporaryFile
  Set-Content -Path $notesTemp -Value $defaultNotes -Encoding UTF8
  $notesArguments = @('--notes-file', $notesTemp)
}

Write-Host "\n🚀 Publication sur GitHub Releases"
Write-Host "  Dépôt : $Repo"
Write-Host "  Tag    : $Tag"
Write-Host "  Titre  : $ReleaseName"
Write-Host "  APK    : $($apk.FullName)" -ForegroundColor Cyan

# Vérifier si la release existe déjà
$releaseExists = $false
try {
  gh release view $Tag --repo $Repo | Out-Null
  $releaseExists = $true
} catch {
  $releaseExists = $false
}

if ($releaseExists) {
  Write-Host "\nℹ️  Release existante détectée pour le tag $Tag. Mise à jour en cours..."
} else {
  Write-Host "\nℹ️  Aucune release pour $Tag. Création en cours..."
}

$resolvedApk = Resolve-Path $ApkPath
$arguments = @('release', 'create', $Tag, $resolvedApk, '--repo', $Repo, '--title', $ReleaseName, '--verify-tag') + $notesArguments

if ($releaseExists) {
  gh release delete-asset $Tag --repo $Repo --yes --pattern "*.apk" | Out-Null
  $arguments = @('release', 'upload', $Tag, $resolvedApk, '--repo', $Repo)
}

try {
  gh @arguments
  Write-Host "\n✅ Publication terminée avec succès." -ForegroundColor Green
} catch {
  Fail "Échec de la publication : $($_.Exception.Message)"
} finally {
  if (-not $NotesFile -and $notesTemp) {
    Remove-Item $notesTemp -ErrorAction SilentlyContinue
  }
}
