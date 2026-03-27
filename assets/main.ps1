# ============================================
# LimpezaDePastas
# ============================================
# Descricao: [Descreva o objetivo do script]
# Autor: [Seu Nome]
# Data: 27/03/2026
# ============================================

# Configuracoes iniciais
$ErrorActionPreference = "Stop"

# ============================================
# FUNCOES
# ============================================

Import-Module -Name "$PSScriptRoot\modules\folderSelect.psm1" -Force
Import-Module -Name "$PSScriptRoot\modules\limparDados.psm1" -Force
Import-Module -Name "$PSScriptRoot\modules\dateSelect.psm1" -Force

function Show-Menu {
    <#
    .SYNOPSIS
        Exibe o menu principal do script
    #>
    Clear-Host
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "   LimpezaDePastas                          " -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[1] Caminho do diretório" -ForegroundColor White
    Write-Host "[0] Sair" -ForegroundColor Red
    Write-Host ""
}

function Confirm-Action {
    param (
        [string]$message
    )

    $confirmation = Read-Host "$message (S/N)"
    return $confirmation -eq "S"
}

function Invoke-Option1 {
    <#
    .SYNOPSIS
        Executa a opcao 1
    #>
    Write-Host "Qual o caminho do diretório?" -ForegroundColor Green
    $caminho = SelectFolder
    $dataSelecionada = DateSelection

    if ($dataSelecionada -and $caminho) {
        $dataInicial = $dataSelecionada[0]
        $dataFinal = $dataSelecionada[1]
        Write-Host "Data Inicial: $($dataInicial.ToShortDateString())" -ForegroundColor Green
        Write-Host "Data Final: $($dataFinal.ToShortDateString())" -ForegroundColor Green
        Write-Host "Caminho selecionado: $caminho" -ForegroundColor Green
        if (Confirm-Action -message "Deseja continuar com esta ação?") {
            Exclude-filesByDate -caminho $caminho -dataInicial $dataInicial -dataFinal $dataFinal
        } else {
            Write-Host "Ação cancelada pelo usuário." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Operação cancelada (pasta ou datas não selecionadas)." -ForegroundColor Yellow
    }
    Read-Host "Pressione Enter para continuar"
}

# ============================================
# LOOP PRINCIPAL
# ============================================

do {
    Show-Menu
    $opcao = Read-Host "Escolha uma opcao"
    
    switch ($opcao) {
        "1" { Invoke-Option1 }
        "0" { 
            Write-Host "Saindo..." -ForegroundColor Yellow
            break 
        }
        default { 
            Write-Host "Opcao invalida!" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($opcao -ne "0")

Write-Host "Programa encerrado." -ForegroundColor Cyan
