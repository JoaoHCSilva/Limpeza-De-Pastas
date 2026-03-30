# LimpezaDePastas

## Descricao

Descreva aqui o objetivo do seu projeto PowerShell.

## Pre-requisitos

- PowerShell 5.1 ou superior
- [Liste aqui outras dependencias necessarias]


## Como Executar

### Opção 1: Via PowerShell
```powershell
.\main.ps1 -Diretorio "C:\Caminho\Para\Pasta" -Idioma "pt-BR"
```

### Opção 2: Via arquivo .bat
Clique duas vezes no arquivo `build.bat` ou execute no terminal:
```cmd
build.bat
```

## Exemplos de Uso

### Limpar uma pasta específica
```powershell
.\main.ps1 -Diretorio "C:\MeusArquivos\Temp"
```

### Limpar múltiplas pastas e definir idioma
```powershell
.\main.ps1 -Diretorio "C:\Temp1","D:\Temp2" -Idioma "pt-BR"
```

### Usar via .bat
```cmd
build.bat "C:\MeusArquivos\Temp" pt-BR
```

## Internacionalização

Todos os textos do script estão preparados para fácil tradução. Para alterar o idioma, utilize o parâmetro `-Idioma` (ex: `pt-BR`, `en-US`).

## Estrutura do Projeto

```
LimpezaDePastas/
â”œâ”€â”€ main.ps1       # Script principal
â”œâ”€â”€ build.bat      # Arquivo para execucao rapida
â”œâ”€â”€ README.md      # Documentacao do projeto
â””â”€â”€ .gitignore     # Arquivos ignorados pelo Git
```

## Autor

João Henrique - [joaohh41@hotmail.com]

## Licenca

Este projeto esta licenciado sob a licenca MIT.
