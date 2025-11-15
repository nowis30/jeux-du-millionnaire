# Script to manually verify an email using admin endpoint
param(
    [string]$Email = "info@job.com",
    [string]$ApiUrl = "https://server-jeux-millionnaire.onrender.com",
    [string]$AdminSecret = ""
)

Write-Host "=== Email Verification Tool ===" -ForegroundColor Cyan
Write-Host "Email: $Email" -ForegroundColor Yellow
Write-Host "API: $ApiUrl" -ForegroundColor Yellow
Write-Host ""

if ([string]::IsNullOrEmpty($AdminSecret)) {
    $AdminSecret = Read-Host "Enter ADMIN_SECRET (from Render env vars)"
}

$verifyUrl = "$ApiUrl/api/auth/admin/verify-user?email=$Email&secret=$AdminSecret"

Write-Host "Sending verification request..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri $verifyUrl -Method GET
    
    Write-Host "✓ Success!" -ForegroundColor Green
    Write-Host "Response: $($response | ConvertTo-Json)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "You can now login with email: $Email" -ForegroundColor Green
}
catch {
    Write-Host "✗ Error:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host $_.ErrorDetails.Message -ForegroundColor Red
    }
}
