# LimpezaDePastas/setup.ps1
$libDir = "$PSScriptRoot\assets\lib"

# Issue 4 fix: fast-path checks all 3 required DLLs
$requiredDlls = @(
    "Microsoft.Web.WebView2.Core.dll",
    "Microsoft.Web.WebView2.WinForms.dll",
    "WebView2Loader.dll"
)
$allPresent = ($requiredDlls | Where-Object { -not (Test-Path "$libDir\$_") }).Count -eq 0
if ($allPresent) {
    Write-Host "WebView2 já instalado em $libDir" -ForegroundColor Green
    exit 0
}

Write-Host "Instalando WebView2 SDK..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $libDir -Force | Out-Null

# Baixa nuget.exe se necessário
$nuget = "$env:TEMP\nuget.exe"
if (-not (Test-Path $nuget)) {
    Write-Host "Baixando NuGet CLI..." -ForegroundColor Yellow
    # Issue 1 fix: wrap Invoke-WebRequest in try/catch
    try {
        Invoke-WebRequest "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile $nuget
    }
    catch {
        Write-Host "Erro: falha ao baixar nuget.exe — $_" -ForegroundColor Red
        exit 1
    }
}

# Baixa o pacote WebView2
# Issue 5 fix: $pkgDir is intentionally left as a local cache between runs
$pkgDir = "$env:TEMP\webview2pkg"
& $nuget install Microsoft.Web.WebView2 -OutputDirectory $pkgDir -NonInteractive | Out-Null
# Issue 1 fix: check exit code after nuget install
if ($LASTEXITCODE -ne 0) {
    Write-Host "Erro: 'nuget install' falhou com código $LASTEXITCODE" -ForegroundColor Red
    exit 1
}

# Localiza a versão baixada
$pkg = Get-ChildItem "$pkgDir\Microsoft.Web.WebView2.*" |
    Sort-Object Name -Descending | Select-Object -First 1

if (-not $pkg) {
    Write-Host "Erro: pacote WebView2 não encontrado em $pkgDir" -ForegroundColor Red
    exit 1
}

# Issue 2 fix: resolve the lib\net4* subfolder dynamically instead of hard-coding net462
$netLibDir = Get-ChildItem "$($pkg.FullName)\lib" -Directory |
    Where-Object { $_.Name -like "net4*" } |
    Sort-Object Name -Descending |
    Select-Object -First 1

if (-not $netLibDir) {
    Write-Host "Erro: nenhuma pasta net4* encontrada em $($pkg.FullName)\lib" -ForegroundColor Red
    exit 1
}

# Issue 3 fix: wrap Copy-Item block in try/catch with a clear error message
# Issue 5 fix: x64 is assumed for WebView2Loader.dll (build\native\x64)
try {
    Copy-Item "$($netLibDir.FullName)\Microsoft.Web.WebView2.Core.dll"     $libDir -Force
    Copy-Item "$($netLibDir.FullName)\Microsoft.Web.WebView2.WinForms.dll" $libDir -Force
    Copy-Item "$($pkg.FullName)\build\native\x64\WebView2Loader.dll"       $libDir -Force
}
catch {
    Write-Host "Erro: falha ao copiar DLLs para $libDir — $_" -ForegroundColor Red
    exit 1
}

Write-Host "WebView2 instalado com sucesso em $libDir" -ForegroundColor Green
Write-Host "DLLs copiadas:" -ForegroundColor Cyan
Get-ChildItem $libDir | ForEach-Object { Write-Host "  $($_.Name)" -ForegroundColor White }
