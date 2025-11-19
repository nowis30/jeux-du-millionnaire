# Script pour créer l'AAB (Android App Bundle) pour Google Play

Write-Host "=== Build AAB pour Google Play ===" -ForegroundColor Cyan

# Étape 1 : Modifier temporairement next.config.mjs pour export
Write-Host "`n[1/6] Configuration Next.js pour export..." -ForegroundColor Yellow
Set-Location "client"

# Backup de la config
if (Test-Path "next.config.mjs") {
    Copy-Item "next.config.mjs" "next.config.mjs.backup" -Force
}

# Créer config pour export
$exportConfig = @"
import withPWA from 'next-pwa';

const isDev = process.env.NODE_ENV !== 'production';
const nextConfig = {
  reactStrictMode: true,
  output: 'export',
  distDir: 'dist',
  experimental: {
    appDir: true,
  },
  images: {
    unoptimized: true,
    domains: ['picsum.photos'],
  },
};

export default withPWA({
  dest: 'public',
  disable: true, // Désactiver SW pour l'export statique mobile
  register: true,
  skipWaiting: true,
})(nextConfig);
"@

Set-Content -Path "next.config.mjs" -Value $exportConfig

# Étape 2 : Build le client
Write-Host "`n[2/6] Build du client Next.js..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur lors du build Next.js" -ForegroundColor Red
    if (Test-Path "next.config.mjs.backup") {
        Move-Item "next.config.mjs.backup" "next.config.mjs" -Force
    }
    exit 1
}

# Étape 3 : Copier vers mobile/dist
Write-Host "`n[3/6] Copie vers mobile/dist..." -ForegroundColor Yellow
Set-Location ..
if (Test-Path "mobile\dist") {
    Remove-Item -Path "mobile\dist" -Recurse -Force -ErrorAction SilentlyContinue
}
Copy-Item -Path "client\dist" -Destination "mobile\dist" -Recurse

# Restaurer la config originale
if (Test-Path "client\next.config.mjs.backup") {
    Move-Item "client\next.config.mjs.backup" "client\next.config.mjs" -Force
}

# Étape 4 : Sync Capacitor
Write-Host "`n[4/6] Sync Capacitor..." -ForegroundColor Yellow
Set-Location "mobile"
npx cap sync android

# Étape 5 : Nettoyer les builds Android
Write-Host "`n[5/6] Nettoyage builds Android..." -ForegroundColor Yellow
if (Test-Path "android\app\build") {
    Remove-Item -Path "android\app\build" -Recurse -Force -ErrorAction SilentlyContinue
}

# Étape 6 : Build AAB via Gradle
Write-Host "`n[6/6] Build AAB Release..." -ForegroundColor Yellow
Set-Location "android"
.\gradlew.bat bundleRelease

if ($LASTEXITCODE -eq 0) {
    $aabPath = "app\build\outputs\bundle\release\app-release.aab"
    if (Test-Path $aabPath) {
        Write-Host "`n=== SUCCÈS ! ===" -ForegroundColor Green
        Write-Host "AAB généré ici : $(Resolve-Path $aabPath)" -ForegroundColor Cyan
        
        # Copier vers le dossier releases pour archivage
        $releaseDir = "..\..\releases"
        if (-not (Test-Path $releaseDir)) { New-Item -ItemType Directory -Path $releaseDir | Out-Null }
        $date = Get-Date -Format "yyyyMMdd-HHmm"
        $dest = "$releaseDir\heritier-millionnaire-release-$date.aab"
        Copy-Item $aabPath $dest
        Write-Host "Copié vers : $dest" -ForegroundColor Cyan
    } else {
        Write-Host "Erreur: Le fichier AAB n'a pas été trouvé malgré le succès de Gradle." -ForegroundColor Red
    }
} else {
    Write-Host "`n=== ÉCHEC DU BUILD GRADLE ===" -ForegroundColor Red
}

Set-Location ..\..
