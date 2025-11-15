# Script pour build l'APK avec le client local (pas Vercel)

Write-Host "=== Build APK avec Client Local ===" -ForegroundColor Cyan

# 1. Build le client Next.js
Write-Host "`n[1/4] Build du client Next.js..." -ForegroundColor Yellow
Set-Location "client"
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur lors du build du client" -ForegroundColor Red
    exit 1
}

# 2. Export le client en static
Write-Host "`n[2/4] Export static du client..." -ForegroundColor Yellow
npx next export -o ../mobile/dist
if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur lors de l'export" -ForegroundColor Red
    exit 1
}

Set-Location ..

# 3. Configurer Capacitor pour utiliser le build local
Write-Host "`n[3/4] Configuration Capacitor..." -ForegroundColor Yellow
Set-Location "mobile"

# Backup du capacitor.config.ts
Copy-Item "capacitor.config.ts" "capacitor.config.ts.backup"

# Créer une config pour build local
$localConfig = @"
import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.heritier.millionnaire',
  appName: 'Héritier Millionnaire',
  webDir: 'dist',
  android: {
    allowMixedContent: false
  }
};

export default config;
"@

Set-Content -Path "capacitor.config.ts" -Value $localConfig

# 4. Sync Capacitor
Write-Host "`n[4/4] Sync Capacitor..." -ForegroundColor Yellow
npx cap sync android
if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur lors du sync Capacitor" -ForegroundColor Red
    # Restaurer la config
    Move-Item "capacitor.config.ts.backup" "capacitor.config.ts" -Force
    exit 1
}

# Restaurer la config originale
Move-Item "capacitor.config.ts.backup" "capacitor.config.ts" -Force

Write-Host "`n=== Build terminé ! ===" -ForegroundColor Green
Write-Host "Maintenant:" -ForegroundColor Cyan
Write-Host "1. Ouvrez Android Studio" -ForegroundColor White
Write-Host "2. Build -> Build APK(s)" -ForegroundColor White
Write-Host "3. L'APK sera dans: mobile/android/app/build/outputs/apk/debug/app-debug.apk" -ForegroundColor White
