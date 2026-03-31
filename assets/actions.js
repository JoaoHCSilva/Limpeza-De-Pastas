// actions.js - Funções de ação: scan e delete

/**
 * Solicita ao backend o escaneamento dos arquivos no período selecionado.
 */
function startScan() {
  const s = document.getElementById('date-start').value
  const e = document.getElementById('date-end').value
  sendToPS('scanFiles', { path: selectedPath, startDate: s, endDate: e })
}

/**
 * Solicita ao backend a exclusão dos arquivos encontrados.
 * Atualiza UI para status de "apagando".
 */
function confirmDelete() {
  if (fileCount === 0) return
  const s      = document.getElementById('date-start').value
  const e      = document.getElementById('date-end').value
  const status = document.getElementById('scan-status')
  status.textContent = '🗑 Apagando arquivos...'
  status.className   = 'scan-status deleting'
  document.getElementById('btn-next').disabled = true
  sendToPS('deleteFiles', { path: selectedPath, startDate: s, endDate: e })
}
