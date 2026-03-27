function DateSelection {
    # Adiciona o tipo necessário para usar Windows Forms
    Add-Type -AssemblyName System.Windows.Forms

    # Cria o formulário principal
    $form = New-Object Windows.Forms.Form
    $form.Text = "Selecione o intervalo de datas" # Título da janela
    $form.Size = New-Object Drawing.Size(300,180) # Tamanho da janela
    $form.StartPosition = "CenterScreen" # Centraliza na tela

    # Label para a data inicial
    $label1 = New-Object Windows.Forms.Label
    $label1.Text = "Data Inicial:"
    $label1.Location = New-Object Drawing.Point(10,20)
    $form.Controls.Add($label1)

    # Controle DateTimePicker para a data inicial
    $dtp1 = New-Object Windows.Forms.DateTimePicker
    $dtp1.Location = New-Object Drawing.Point(100,15)
    $dtp1.Format = 'Short' # Formato de data curto (dd/MM/yyyy)
    $form.Controls.Add($dtp1)

    # Label para a data final
    $label2 = New-Object Windows.Forms.Label
    $label2.Text = "Data Final:"
    $label2.Location = New-Object Drawing.Point(10,60)
    $form.Controls.Add($label2)

    # Controle DateTimePicker para a data final
    $dtp2 = New-Object Windows.Forms.DateTimePicker
    $dtp2.Location = New-Object Drawing.Point(100,55)
    $dtp2.Format = 'Short' # Formato de data curto
    $form.Controls.Add($dtp2)

    # Botão OK para confirmar a seleção
    $okButton = New-Object Windows.Forms.Button
    $okButton.Text = "OK"
    $okButton.Location = New-Object Drawing.Point(100,100)
    # Ao clicar, define o resultado do formulário como OK (fecha a janela)
    $okButton.Add_Click({ $form.DialogResult = [Windows.Forms.DialogResult]::OK })
    $form.Controls.Add($okButton)

    # Exibe o formulário e retorna as datas selecionadas se o usuário clicar em OK
    if ($form.ShowDialog() -eq [Windows.Forms.DialogResult]::OK) {
        return @($dtp1.Value, $dtp2.Value) # Retorna as datas como array
    } else {
        return $null # Retorna nulo se o usuário cancelar
    }
}
Export-ModuleMember -Function DateSelection