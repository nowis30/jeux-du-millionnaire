# Script pour nettoyer et forcer rebuild Android

Write-Host "=== Nettoyage complet Android ===" -ForegroundColor Cyan

Set-Location "mobile\android"

Write-Host "`n[1/5] Suppression des builds..." -ForegroundColor Yellow
Remove-Item -Path "app\build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".gradle" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".idea" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n[2/5] Suppression du cache Gradle global..." -ForegroundColor Yellow
$gradleHome = "$env:USERPROFILE\.gradle"
if (Test-Path "$gradleHome\caches") {
    Remove-Item -Path "$gradleHome\caches" -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "`n[3/5] Retour au dossier mobile..." -ForegroundColor Yellow
Set-Location ".."

Write-Host "`n[4/5] Sync Capacitor..." -ForegroundColor Yellow
npx cap sync android

Write-Host "`n[5/5] Ouverture Android Studio..." -ForegroundColor Yellow
npx cap open android

Write-Host "`n=== Nettoyage terminé ! ===" -ForegroundColor Green
Write-Host "`nDans Android Studio:" -ForegroundColor Cyan
Write-Host "1. Attendez la fin de Gradle sync" -ForegroundColor White
Write-Host "2. File -> Invalidate Caches / Restart" -ForegroundColor White
Write-Host "3. Build -> Rebuild Project" -ForegroundColor White
Write-Host "4. Build -> Build APK(s)" -ForegroundColor White
