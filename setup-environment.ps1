# Android Development Environment Setup Script
Write-Host "Setting up Android development environment..." -ForegroundColor Green

# Check Java installation (try as Administrator)
try {
    $javaVersion = & runas /user:Administrator "java -version 2>&1" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Java found in Administrator context" -ForegroundColor Green
        Write-Host "Note: You may need to run builds as Administrator" -ForegroundColor Yellow
    } else {
        throw "Java not found"
    }
} catch {
    Write-Host "ERROR: Java JDK is not accessible" -ForegroundColor Red
    Write-Host "Please ensure Java is installed and accessible" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check Android SDK - try multiple locations
$sdkPaths = @(
    "$env:LOCALAPPDATA\Android\Sdk",
    "C:\Users\Administrator\AppData\Local\Android\Sdk",
    "C:\Program Files\Android\android-sdk",
    "C:\Program Files (x86)\Android\android-sdk"
)

$sdkFound = $false
foreach ($path in $sdkPaths) {
    if (Test-Path $path) {
        Write-Host "Android SDK found at: $path" -ForegroundColor Green
        $sdkFound = $true

        # Update local.properties if needed
        $localPropsPath = ".\app\local.properties"
        if (Test-Path $localPropsPath) {
            $content = Get-Content $localPropsPath -Raw
            $newContent = $content -replace "sdk\.dir=.*", "sdk.dir=$($path -replace '\\', '\\')"
            Set-Content $localPropsPath $newContent
            Write-Host "Updated local.properties with SDK path" -ForegroundColor Green
        }
        break
    }
}

if (-not $sdkFound) {
    Write-Host "WARNING: Android SDK not found in common locations" -ForegroundColor Yellow
    Write-Host "Please install Android SDK through Android Studio" -ForegroundColor Yellow
    Write-Host "Or manually install from: https://developer.android.com/studio#downloads" -ForegroundColor Yellow
}

Write-Host "Environment setup complete!" -ForegroundColor Green
Write-Host "Note: You may need to run 'build-as-admin.bat' for building" -ForegroundColor Yellow
Read-Host "Press Enter to continue"