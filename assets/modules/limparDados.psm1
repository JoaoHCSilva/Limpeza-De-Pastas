# LimpezaDePastas/assets/modules/limparDados.psm1

function Get-FilesByDate {
    <#
    .SYNOPSIS
        Retorna lista de arquivos dentro do intervalo de datas, sem deletar.
    #>
    param (
        [string]$caminho,
        [string]$dataInicial,
        [string]$dataFinal
    )

    if (-not (Test-Path -Path $caminho)) {
        return @{ erro = "Caminho não encontrado: $caminho" }
    }

    $inicio = [datetime]$dataInicial
    $fim    = [datetime]$dataFinal

    $arquivos = Get-ChildItem -Path $caminho -Recurse -File |
        Where-Object { $_.LastWriteTime -ge $inicio -and $_.LastWriteTime -le $fim } |
        Select-Object -ExpandProperty FullName

    return @{
        total    = $arquivos.Count
        arquivos = @($arquivos)
    }
}

function Exclude-filesByDate {
    <#
    .SYNOPSIS
        Remove arquivos dentro do intervalo de datas (modo simulado com -WhatIf).
    #>
    param (
        [string]$caminho,
        [string]$dataInicial,
        [string]$dataFinal
    )

    if (-not (Test-Path -Path $caminho)) {
        Write-Host "O caminho especificado não existe: $caminho está correto de fato?" -ForegroundColor Red
        return
    }

    $inicio = [datetime]$dataInicial
    $fim    = [datetime]$dataFinal

    $arquivosParaRemover = Get-ChildItem -Path $caminho -Recurse -File |
        Where-Object { $_.LastWriteTime -ge $inicio -and $_.LastWriteTime -le $fim }

    if (-not $arquivosParaRemover) {
        Write-Host "Nenhum arquivo encontrado para remover." -ForegroundColor Yellow
        return
    }

    Write-Host "Foram encontrados $($arquivosParaRemover.Count) arquivos para remover." -ForegroundColor Yellow
    $arquivosParaRemover | Remove-Item -Force -WhatIf
    Write-Host "Remoção simulada concluída." -ForegroundColor Green
}

Export-ModuleMember -Function Get-FilesByDate, Exclude-filesByDate
