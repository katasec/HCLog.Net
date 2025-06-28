# PowerShell script to pack and publish HCLog.Net to NuGet

$ErrorActionPreference = "Stop"

# --- Configuration ---
$projectPath = "src/HCLog.Net/HCLog.Net.csproj"
$outputDir = "artifacts"
$nugetSource = "https://api.nuget.org/v3/index.json"
$readmePath = "README.md"

# --- Step 1: Get latest Git tag and parse version ---
$tag = git describe --tags --abbrev=0
if ($tag -match "^v(\d+\.\d+\.\d+)$") {
    $version = $Matches[1]
} else {
    Write-Error "❌ Git tag '$tag' is not in SemVer format (vX.Y.Z)"
    exit 1
}
Write-Host "🔖 Using version: $version"

# --- Step 2: Verify README exists ---
if (-not (Test-Path $readmePath)) {
    Write-Error "❌ README.md file not found at root. Required for NuGet packaging."
    exit 1
}

# --- Step 3: Clean previous artifacts ---
if (Test-Path $outputDir) { Remove-Item -Recurse -Force $outputDir }
New-Item -ItemType Directory -Path $outputDir | Out-Null

# --- Step 4: Build and Pack ---
dotnet clean $projectPath
dotnet build $projectPath -c Release

dotnet pack $projectPath `
    -c Release `
    -o $outputDir `
    -p:PackageVersion=$version `
    -p:IncludeSymbols=true `
    -p:SymbolPackageFormat=snupkg `
    -p:PackageReadmeFile=README.md

# --- Step 5: Locate package ---
$nupkg = Get-ChildItem "$outputDir\*.nupkg" | Where-Object { $_.Name -notlike "*.symbols.nupkg" } | Select-Object -First 1
if (-not $nupkg) {
    Write-Error "❌ No .nupkg file found in $outputDir"
    exit 1
}
Write-Host "📦 Found package: $($nupkg.FullName)"

# --- Step 6: Push to NuGet ---
if (-not $env:NUGET_API_KEY) {
    Write-Error "❌ Environment variable NUGET_API_KEY is not set"
    exit 1
}

dotnet nuget push $nupkg.FullName `
    --api-key $env:NUGET_API_KEY `
    --source $nugetSource `
    --skip-duplicate

Write-Host "✅ Published $($nupkg.Name) to NuGet"
