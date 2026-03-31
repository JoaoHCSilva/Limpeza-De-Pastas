// bridge.js - Comunicação com backend PowerShell via WebView2

/**
 * Envia mensagem para o backend PowerShell via WebView2.
 * @param {string} action - Nome da ação (ex: 'openFolder', 'scanFiles', 'deleteFiles')
 * @param {object} payload - Dados adicionais para a ação
 */
function sendToPS(action, payload) {
  chrome.webview.postMessage(JSON.stringify({ action, ...(payload || {}) }))
}

/**
 * Recebe mensagens do backend PowerShell e atualiza a UI conforme ação.
 * @param {string} jsonStr - Mensagem JSON serializada
 */
function receiveMessage(jsonStr) {
  const msg = JSON.parse(jsonStr)
  if (msg.action === 'folderSelected') {
    selectedPath = msg.path
    document.getElementById('folder-path').textContent = msg.path
    document.getElementById('folder-display').style.display = 'block'
    document.getElementById('folder-drop').style.display    = 'none'
    document.getElementById('btn-next').disabled = false
  }
  else if (msg.action === 'scanResult') {
    const status   = document.getElementById('scan-status')
    const fileList = document.getElementById('file-list')
    fileCount = msg.total
    if (msg.erro) {
      status.textContent = '❌ ' + msg.erro
      status.className   = 'scan-status error'
      return
    }
    if (msg.total === 0) {
      status.textContent = '⚠ Nenhum arquivo encontrado no período.'
      status.className   = 'scan-status empty'
      return
    }
    status.textContent = '✓ ' + msg.total + ' arquivo(s) encontrado(s)'
    status.className   = 'scan-status done'
    fileList.style.display = 'block'
    fileList.innerHTML = ''
    msg.arquivos.forEach(f => {
      const div = document.createElement('div')
      div.className = 'file-item'
      div.textContent = f
      fileList.appendChild(div)
    })
    document.getElementById('btn-next').disabled = false
  }
  else if (msg.action === 'deleteResult') {
    const status = document.getElementById('scan-status')
    const pastasTxt = msg.pastas > 0 ? ` e ${msg.pastas} pasta(s) removida(s)` : ''
    status.textContent = '✓ Limpeza concluída. ' + msg.total + ' arquivo(s)' + pastasTxt + '.'
    status.className   = 'scan-status done'
    document.getElementById('btn-back').style.display  = 'none'
    document.getElementById('btn-next').style.display  = 'none'
    document.getElementById('btn-new-clean').style.display = 'block'
  }
}
