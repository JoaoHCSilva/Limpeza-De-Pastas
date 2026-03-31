# ============================================
# LimpezaDePastas — WebView2 Host
# ============================================
# Descricao: Interface grafica via WebView2 para limpeza de arquivos por data
# Data: 27/03/2026
# ============================================

$ErrorActionPreference = "Stop"

# ── Dependências ──────────────────────────────────────────
$libDir = "$PSScriptRoot\lib"
if (-not (Test-Path "$libDir\Microsoft.Web.WebView2.WinForms.dll")) {
    Write-Host "DLLs do WebView2 não encontradas. Execute setup.ps1 primeiro." -ForegroundColor Red
    Read-Host "Pressione Enter para sair"
    exit 1
}

Add-Type -Path "$libDir\Microsoft.Web.WebView2.Core.dll"
Add-Type -Path "$libDir\Microsoft.Web.WebView2.WinForms.dll"
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing


Import-Module -Name "$PSScriptRoot\modules\limparDados.psm1" -Force
Import-Module -Name "$PSScriptRoot\modules\jsBridge.psm1" -Force



# ── Janela principal ──────────────────────────────────────
$script:form                 = New-Object System.Windows.Forms.Form
$script:form.Text            = "LimpezaDePastas"
$script:form.Size            = New-Object System.Drawing.Size(500, 620)
$script:form.StartPosition   = "CenterScreen"
$script:form.FormBorderStyle = "FixedSingle"
$script:form.MaximizeBox     = $false
$script:form.BackColor       = [System.Drawing.Color]::FromArgb(15, 15, 15)

# ── Controle WebView2 ─────────────────────────────────────
# Usar $script: garante acesso ao $webview dentro de script blocks aninhados
$script:webview      = New-Object Microsoft.Web.WebView2.WinForms.WebView2
$script:webview.Dock = [System.Windows.Forms.DockStyle]::Fill
$script:form.Controls.Add($script:webview)

# ── Inicialização do WebView2 ─────────────────────────────
# Capturar $PSScriptRoot antes do handler (não disponível dentro de script blocks .NET)
$script:htmlPath = ("file:///" + "$PSScriptRoot\app.html") -replace '\\', '/'

$script:webview.add_CoreWebView2InitializationCompleted({
    param($wv2Sender, $initArgs)
    if (-not $initArgs.IsSuccess) {
        Write-Host "Erro ao inicializar WebView2: $($initArgs.InitializationException.Message)" -ForegroundColor Red
        return
    }
    if (-not $script:webview.CoreWebView2) { return }
    $script:webview.CoreWebView2.Navigate($script:htmlPath)

    $script:webview.CoreWebView2.add_WebMessageReceived({
        param($msgSender, $msgArgs)
        try {
            # WebMessageAsString é vazio nesta versão do WebView2 para mensagens JSON.
            # WebMessageAsJson retorna a mensagem duplamente codificada ("\"{ ... }\""),
            # por isso dois ConvertFrom-Json: primeiro desempacota a string, depois parseia o objeto.
            $msg = $msgArgs.WebMessageAsJson | ConvertFrom-Json | ConvertFrom-Json

            switch ($msg.action) {
                'openFolder' {
                    $script:selectedFolderPath = $null
                    $script:form.Invoke([Action]{
                        $dialog             = New-Object System.Windows.Forms.FolderBrowserDialog
                        $dialog.Description = "Selecione a pasta alvo para limpeza"
                        if ($dialog.ShowDialog($script:form) -eq [System.Windows.Forms.DialogResult]::OK) {
                            $script:selectedFolderPath = $dialog.SelectedPath
                        }
                    })
                    if ($script:selectedFolderPath) {
                        Send-ToJS -webview $script:webview -data @{ action = 'folderSelected'; path = $script:selectedFolderPath }
                    }
                }
                'scanFiles' {
                    $resultado = Get-FilesByDate -caminho $msg.path -dataInicial $msg.startDate -dataFinal $msg.endDate
                    $scanResult = if ($resultado.erro) {
                        @{ action = 'scanResult'; total = 0; arquivos = @(); erro = $resultado.erro }
                    } else {
                        @{ action = 'scanResult'; total = $resultado.total; arquivos = $resultado.arquivos }
                    }
                    Send-ToJS -webview $script:webview -data $scanResult
                }
                'deleteFiles' {
                    $resultado = Exclude-filesByDate -caminho $msg.path -dataInicial $msg.startDate -dataFinal $msg.endDate
                    Send-ToJS -webview $script:webview -data @{ action = 'deleteResult'; total = $resultado.totalArquivos; pastas = $resultado.totalPastas }
                }
            }
        }
        catch {
            Send-ToJS -webview $script:webview -data @{ action = 'scanResult'; total = 0; erro = $_.Exception.Message; arquivos = @() }
        }
    })
})

$wv2UserDataFolder = "$env:TEMP\LimpezaDePastasWV2"
$wv2Env = [Microsoft.Web.WebView2.Core.CoreWebView2Environment]::CreateAsync("", $wv2UserDataFolder).GetAwaiter().GetResult()
$script:webview.EnsureCoreWebView2Async($wv2Env) | Out-Null

[System.Windows.Forms.Application]::Run($script:form)
