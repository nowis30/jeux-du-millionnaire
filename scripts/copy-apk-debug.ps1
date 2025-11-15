param(
  [string]$SourceApk = "$PSScriptRoot\..\mobile\android\app\build\outputs\apk\debug\app-debug.apk",
  [string]$DestDir = "$PSScriptRoot\..\releases"
)

if (-not (Test-Path $SourceApk)) {
  Write-Error "APK debug introuvable: $SourceApk. Exécutez d'abord gradlew assembleDebug."
  exit 1
}

if (-not (Test-Path $DestDir)) {
  New-Item -ItemType Directory -Path $DestDir | Out-Null
}

$ts = Get-Date -Format "yyyyMMdd-HHmm"
$outName = "heritier-millionnaire-debug-$ts.apk"
$destApk = Join-Path $DestDir $outName
Copy-Item $SourceApk $destApk -Force
Write-Host "APK debug copié vers: $destApk"
