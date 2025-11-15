# Script pour préparer l'APK avec pubs fonctionnelles

Write-Host "=== Preparation APK avec AdMob ===" -ForegroundColor Cyan

# Étape 1 : Créer un dossier dist minimal avec redirection vers Vercel
Write-Host "`n[1/3] Creation du dist minimal..." -ForegroundColor Yellow
Set-Location "mobile"

# Créer le dossier dist s'il n'existe pas
if (!(Test-Path "dist")) {
    New-Item -ItemType Directory -Path "dist" | Out-Null
}

# Créer un index.html qui redirige vers Vercel MAIS inclut Capacitor
$html = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Héritier Millionnaire</title>
    <script src="capacitor.js"></script>
    <script>
        // Redirection immediate vers Vercel une fois Capacitor chargé
        window.addEventListener('capacitorReady', () => {
            console.log('Capacitor ready, redirecting to Vercel...');
            window.location.href = 'https://client-jeux-millionnaire.vercel.app';
        });
        
        // Fallback si capacitorReady ne se déclenche pas
        setTimeout(() => {
            if (!window.Capacitor) {
                window.location.href = 'https://client-jeux-millionnaire.vercel.app';
            }
        }, 3000);
    </script>
</head>
<body>
    <div style="display: flex; align-items: center; justify-center: center; height: 100vh; font-family: sans-serif;">
        <p>Chargement...</p>
    </div>
</body>
</html>
"@

Set-Content -Path "dist/index.html" -Value $html

# Étape 2 : Modifier capacitor.config pour utiliser webDir
Write-Host "`n[2/3] Configuration Capacitor pour build local..." -ForegroundColor Yellow

$newConfig = @"
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

Set-Content -Path "capacitor.config.ts" -Value $newConfig

# Étape 3 : Sync Capacitor
Write-Host "`n[3/3] Sync Capacitor..." -ForegroundColor Yellow
npx cap sync android

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n=== Preparation terminée ! ===" -ForegroundColor Green
    Write-Host "`nMaintenant:" -ForegroundColor Cyan
    Write-Host "1. npx cap open android" -ForegroundColor White
    Write-Host "2. Build -> Build APK(s)" -ForegroundColor White
    Write-Host "3. Installez l'APK sur votre téléphone" -ForegroundColor White
    Write-Host "`nL'app chargera Vercel AVEC Capacitor actif !" -ForegroundColor Yellow
} else {
    Write-Host "`nErreur lors du sync" -ForegroundColor Red
    exit 1
}
