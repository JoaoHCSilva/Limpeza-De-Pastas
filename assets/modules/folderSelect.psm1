function SelectFolder {

    Add-Type -AssemblyName System.Windows.Forms # Carrega a biblioteca de formulários do Windows

    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog # Cria uma nova instância do seletor de pastas

    # Exibe a janela de seleção de pasta e verifica se o usuário selecionou uma pasta
    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $caminho = $folderBrowser.SelectedPath
        return $caminho
    } else {
        Write-Host "Nenhuma pasta selecionada."
        return $null
    }
}

Export-ModuleMember -Function SelectFolder