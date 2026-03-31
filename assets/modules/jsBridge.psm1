# Module: jsBridge.psm1
# Funções utilitárias para comunicação PowerShell <-> JavaScript via WebView2

function Send-ToJS {
    <#
    .SYNOPSIS
        Envia dados serializados para o frontend JS via WebView2.
    .PARAMETER webview
        Instância do controle WebView2.
    .PARAMETER data
        Objeto a ser serializado e enviado.
    #>
    param(
        [Parameter(Mandatory)]
        [Microsoft.Web.WebView2.WinForms.WebView2]$webview,
        [Parameter(Mandatory)]
        [object]$data
    )
    $json    = $data | ConvertTo-Json -Compress -Depth 10
    # Escapar backslashes primeiro (JSON já tem \\, JS precisa de \\\\), depois single quotes
    $escaped = $json -replace '\\', '\\\\' -replace "'", "\\'"
    $webview.CoreWebView2.ExecuteScriptAsync("receiveMessage('$escaped')") | Out-Null
}

Export-ModuleMember -Function Send-ToJS
