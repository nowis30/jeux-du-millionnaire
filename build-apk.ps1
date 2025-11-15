# Script PowerShell pour builder l'APK Android
# Usage: .\build-apk.ps1 [debug|release]

param(
    [Parameter(Position=0)]
    [ValidateSet("debug", "release")]
    [string]$BuildType = "debug"
)

Write-Host "Build APK Android - Type: $BuildType" -ForegroundColor Cyan
Write-Host ""

# Etape 1: Sync Capacitor
Write-Host "Etape 1/3: Synchronisation Capacitor..." -ForegroundColor Yellow
Set-Location "mobile"
npx cap sync
if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur lors du sync Capacitor" -ForegroundColor Red
    exit 1
}
Write-Host "Sync OK" -ForegroundColor Green
Write-Host ""

# Etape 2: Build APK
Write-Host "Etape 2/3: Build APK $BuildType..." -ForegroundColor Yellow
Set-Location "android"

if ($BuildType -eq "debug") {
    ./gradlew assembleDebug
    $apkPath = "app/build/outputs/apk/debug/app-debug.apk"
} else {
    ./gradlew assembleRelease
    $apkPath = "app/build/outputs/apk/release/app-release.apk"
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur lors du build" -ForegroundColor Red
    Set-Location "../.."
    exit 1
}
Write-Host "Build OK" -ForegroundColor Green
Write-Host ""

# Etape 3: Copier et renommer l'APK
Write-Host "Etape 3/3: Copie de l'APK..." -ForegroundColor Yellow
$date = Get-Date -Format "yyyyMMdd-HHmm"
$outputName = "heritier-millionnaire-$BuildType-$date.apk"
$outputPath = "../../$outputName"

Copy-Item $apkPath $outputPath
Set-Location "../.."

if (Test-Path $outputName) {
    Write-Host "APK cree avec succes!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Fichier: $outputName" -ForegroundColor Cyan
    Write-Host "Taille: $((Get-Item $outputName).Length / 1MB -as [int]) MB" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Prochaines etapes:" -ForegroundColor Yellow
    Write-Host "  1. Transferer l'APK sur un telephone Android" -ForegroundColor White
    Write-Host "  2. Installer et tester l'application" -ForegroundColor White
    Write-Host "  3. Verifier que les annonces AdMob s'affichent" -ForegroundColor White
    Write-Host "  4. Uploader sur GitHub Releases: https://github.com/nowis30/jeux-millionnaire-APK/releases" -ForegroundColor White
    Write-Host ""
    
    # Ouvrir l'explorateur de fichiers
    explorer.exe /select,"$pwd\$outputName"
} else {
    Write-Host "Erreur: APK non trouve" -ForegroundColor Red
    exit 1
}
