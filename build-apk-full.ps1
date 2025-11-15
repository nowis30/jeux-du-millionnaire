# Script pour créer l'APK avec le vrai jeu (pas juste la page de test)

Write-Host "=== Build APK avec le vrai jeu ===" -ForegroundColor Cyan

# Étape 1 : Modifier temporairement next.config.mjs pour export
Write-Host "`n[1/6] Configuration Next.js pour export..." -ForegroundColor Yellow
Set-Location "client"

# Backup de la config
Copy-Item "next.config.mjs" "next.config.mjs.backup"

# Créer config pour export
$exportConfig = @"
import withPWA from 'next-pwa';

const isDev = process.env.NODE_ENV !== 'production';

export default withPWA({
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
  pwa: {
    dest: 'public',
    disable: true,
    register: true,
    skipWaiting: true,
  },
});
"@

Set-Content -Path "next.config.mjs" -Value $exportConfig

# Étape 2 : Build le client
Write-Host "`n[2/6] Build du client Next.js..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur lors du build" -ForegroundColor Red
    Move-Item "next.config.mjs.backup" "next.config.mjs" -Force
    exit 1
}

# Étape 3 : Copier vers mobile/dist
Write-Host "`n[3/6] Copie vers mobile/dist..." -ForegroundColor Yellow
Set-Location ..
Remove-Item -Path "mobile\dist" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item -Path "client\dist" -Destination "mobile\dist" -Recurse

# Restaurer la config originale
Move-Item "client\next.config.mjs.backup" "client\next.config.mjs" -Force

# Étape 4 : Sync Capacitor
Write-Host "`n[4/6] Sync Capacitor..." -ForegroundColor Yellow
Set-Location "mobile"
npx cap sync android

# Étape 5 : Nettoyer les builds Android
Write-Host "`n[5/6] Nettoyage builds Android..." -ForegroundColor Yellow
Remove-Item -Path "android\app\build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "android\build" -Recurse -Force -ErrorAction SilentlyContinue

# Étape 6 : Ouvrir Android Studio
Write-Host "`n[6/6] Ouverture Android Studio..." -ForegroundColor Yellow
npx cap open android

Write-Host "`n=== Préparation terminée ! ===" -ForegroundColor Green
Write-Host "`nDans Android Studio:" -ForegroundColor Cyan
Write-Host "1. Build -> Rebuild Project" -ForegroundColor White
Write-Host "2. Build -> Build APK(s)" -ForegroundColor White
Write-Host "`nL'app chargera maintenant le vrai jeu avec les pubs fonctionnelles !" -ForegroundColor Yellow
