# PowerShell script to build, pack, and push HCLog.Net to NuGet

# Fail on any error
$ErrorActionPreference = "Stop"

# --- Configuration ---
$projectPath = "src/HCLog.Net/HCLog.Net.csproj"
$outputDir = "artifacts"
$nugetSource = "https://api.nuget.org/v3/index.json"

# --- Step 1: Get the latest Git tag (assumes tags like v1.2.3) ---
$tag = git describe --tags --abbrev=0
if ($tag -match "^v(\d+\.\d+\.\d+)$") {
    $version = $Matches[1]
} else {
    Write-Error "❌ Latest Git tag '$tag' is not in valid SemVer format (vX.Y.Z)"
    exit 1
}

Write-Host "🔖 Using version: $version"

# --- Step 2: Build and pack the project ---
dotnet clean $projectPath
dotnet build $projectPath -c Release

dotnet pack $projectPath `
    -c Release `
    -o $outputDir `
    -p:PackageVersion=$version `
    -p:IncludeSymbols=true `
    -p:SymbolPackageFormat=snupkg

# --- Step 3: Find the .nupkg ---
$nupkg = Get-ChildItem "$outputDir\*.nupkg" | Where-Object { $_.Name -notlike "*.symbols.nupkg" } | Select-Object -First 1
if (-not $nupkg) {
    Write-Error "❌ No .nupkg file found in $outputDir"
    exit 1
}

Write-Host "📦 Found package: $($nupkg.FullName)"

# --- Step 4: Push to NuGet (requires NUGET_API_KEY env var) ---
if (-not $env:NUGET_API_KEY) {
    Write-Error "❌ Environment variable NUGET_API_KEY is not set"
    exit 1
}

dotnet nuget push $nupkg.FullName `
    --api-key $env:NUGET_API_KEY `
    --source $nugetSource `
    --skip-duplicate

Write-Host "✅ Published $($nupkg.Name) to NuGet"
