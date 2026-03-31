# LimpezaDePastas/assets/modules/limparDados.psm1


# Função utilitária para filtrar arquivos por data
function Get-FilesInDateRange {
    <#
    .SYNOPSIS
        Retorna objetos de arquivos dentro do intervalo de datas especificado.
    #>
    param (
        [string]$caminho,
        [datetime]$inicio,
        [datetime]$fim
    )
    if (-not (Test-Path -Path $caminho)) {
        return @()
    }
    return Get-ChildItem -Path $caminho -Recurse -File |
        Where-Object { $_.LastWriteTime -ge $inicio -and $_.LastWriteTime -le $fim }
}

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

    $arquivos = Get-FilesInDateRange -caminho $caminho -inicio $inicio -fim $fim | Select-Object -ExpandProperty FullName

    return @{
        total    = $arquivos.Count
        arquivos = @($arquivos)
    }
}


function Exclude-filesByDate {
    <#
    .SYNOPSIS
        Remove arquivos no intervalo de datas e subpastas que ficarem vazias.
        Retorna @{ totalArquivos = N; totalPastas = M }.
    #>
    param (
        [string]$caminho,
        [string]$dataInicial,
        [string]$dataFinal
    )

    if (-not (Test-Path -Path $caminho)) {
        Write-Host "O caminho especificado não existe: $caminho" -ForegroundColor Red
        return @{ totalArquivos = 0; totalPastas = 0 }
    }

    $inicio = [datetime]$dataInicial
    $fim    = [datetime]$dataFinal

    # ── 1. Remover arquivos no intervalo ──────────────────────
    $arquivosParaRemover = Get-FilesInDateRange -caminho $caminho -inicio $inicio -fim $fim

    $totalArquivos = 0
    if ($arquivosParaRemover) {
        $totalArquivos = @($arquivosParaRemover).Count
        $arquivosParaRemover | Remove-Item -Force
    }

    # ── 2. Remover subpastas vazias (filhos antes dos pais) ───
    $totalPastas = 0
    Get-ChildItem -Path $caminho -Recurse -Directory |
        Sort-Object { $_.FullName.Length } -Descending |
        ForEach-Object {
            if (Test-Path -Path $_.FullName) {
                $conteudo = Get-ChildItem -Path $_.FullName -Force -ErrorAction SilentlyContinue
                if ($conteudo.Count -eq 0) {
                    Remove-Item -Path $_.FullName -Force
                    $totalPastas++
                }
            }
        }

    return @{ totalArquivos = $totalArquivos; totalPastas = $totalPastas }
}

Export-ModuleMember -Function Get-FilesByDate, Exclude-filesByDate, Get-FilesInDateRange
