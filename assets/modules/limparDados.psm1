function Exclude-filesByDate {
    param (
        [string]$caminho,
        [string]$dataInicial,
        [string]$dataFinal
    )
 
    # Verificar se o caminho existe
    if (Test-Path -Path $caminho) {
        $dataInicial = [datetime]$dataInicial
        $dataFinal = [datetime]$dataFinal

        # Obter arquivos dentro do intervalo de datas e remover
        $arquivosParaRemover = Get-ChildItem -Path $caminho -Recurse | Where-Object {
            $_.LastWriteTime -ge $dataInicial -and $_.LastWriteTime -le $dataFinal
        }
    } else {
        Write-Host "O caminho especificado não existe: $caminho está correto de fato?" -ForegroundColor Red
        return
    }

    # Verificar se foram encontrados arquivos para remover
    if (-not $arquivosParaRemover) {
        Write-Host "Nenhum arquivo encontrado para remover." -ForegroundColor Yellow
        return
    }

    # Remover os arquivos encontrados
    Write-Host "Foram encontrados $($arquivosParaRemover.Count) arquivos para remover." -ForegroundColor Yellow
    $arquivosParaRemover | Remove-Item -Force 
    Write-Host "Remoção simulada concluída. Verifique os arquivos listados acima." -ForegroundColor Green
}

Export-ModuleMember -Function Exclude-filesByDate