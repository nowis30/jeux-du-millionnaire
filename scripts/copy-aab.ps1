param(
  [string]$SourceAab = "$PSScriptRoot\..\mobile\android\app\build\outputs\bundle\release\app-release.aab",
  [string]$DestDir = "$PSScriptRoot\..\releases"
)

if (-not (Test-Path $SourceAab)) {
  Write-Error "AAB introuvable: $SourceAab. Exécutez d'abord gradlew bundleRelease."
  exit 1
}

if (-not (Test-Path $DestDir)) {
  New-Item -ItemType Directory -Path $DestDir | Out-Null
}

# Essayer de lire versionCode/versionName depuis build.gradle
$buildGradle = Join-Path $PSScriptRoot "..\mobile\android\app\build.gradle"
$versionName = $null
$versionCode = $null
if (Test-Path $buildGradle) {
  $text = Get-Content $buildGradle -Raw
  if ($text -match 'versionName\s+"([^"]+)"') { $versionName = $matches[1] }
  if ($text -match 'versionCode\s+(\d+)') { $versionCode = $matches[1] }
}

$ts = Get-Date -Format "yyyyMMdd-HHmm"
$baseName = "heritier-millionnaire"
if ($versionName -and $versionCode) {
  $outName = "$baseName-$versionName($versionCode)-$ts.aab"
} else {
  $outName = "$baseName-$ts.aab"
}

$destAab = Join-Path $DestDir $outName
Copy-Item $SourceAab $destAab -Force
Write-Host "AAB copié vers: $destAab"
