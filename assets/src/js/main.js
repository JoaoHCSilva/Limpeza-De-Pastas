// LimpezaDePastas - main.js
// Todas as funções estão comentadas para facilitar manutenção futura.

// Estado global do wizard
let currentStep = 1
let selectedPath = ''
let fileCount = 0

// Inicialização da tela e datas padrão
window.onload = () => {
  // Define datas padrão: início do ano até hoje
  const today = new Date()
  const firstDay = new Date(today.getFullYear(), 0, 1)
  document.getElementById('date-start').value = formatDate(firstDay)
  document.getElementById('date-end').value   = formatDate(today)
  updatePeriodInfo()
}

/**
 * Atualiza o texto informativo do período selecionado (quantidade de dias).
 * Exibe mensagem apenas se datas válidas e ordem correta.
 */
function updatePeriodInfo() {
  const s  = new Date(document.getElementById('date-start').value)
  const e  = new Date(document.getElementById('date-end').value)
  const el = document.getElementById('period-info')
  if (!isNaN(s) && !isNaN(e) && e >= s) {
    const days = Math.round((e - s) / 86400000) + 1
    el.textContent = `Período selecionado: ${days} dia(s)`
  } else {
    el.textContent = ''
  }
}

/**
 * Formata um objeto Date para string ISO (yyyy-mm-dd) para campos <input type="date">.
 */
function formatDate(d) {
  return d.toISOString().split('T')[0]
}

/**
 * Avança para o próximo passo do wizard, validando dados conforme necessário.
 * Passo 1: exige pasta selecionada. Passo 2: exige datas válidas.
 */
function goNext() {
  if (currentStep === 1) {
    if (!selectedPath) return
    document.getElementById('folder-path-2').textContent = selectedPath
    setStep(2)
  } else if (currentStep === 2) {
    const s = document.getElementById('date-start').value
    const e = document.getElementById('date-end').value
    if (new Date(e) < new Date(s)) {
      document.getElementById('date-error').style.display = 'block'
      return
    }
    document.getElementById('date-error').style.display = 'none'
    document.getElementById('summary-path').textContent  = selectedPath
    document.getElementById('summary-dates').textContent =
      formatDateBR(s) + ' → ' + formatDateBR(e)
    setStep(3)
    startScan()
  }
}

/**
 * Volta um passo no wizard.
 */
function goBack() {
  if (currentStep > 1) setStep(currentStep - 1)
}

/**
 * Formata data ISO (yyyy-mm-dd) para formato brasileiro (dd/mm/yyyy).
 */
function formatDateBR(iso) {
  const [y, m, d] = iso.split('-')
  return `${d}/${m}/${y}`
}

/**
 * Ativa o passo do wizard e atualiza UI dos steps e footer.
 * @param {number} n - Passo a ativar (1, 2 ou 3)
 */
function setStep(n) {
  document.getElementById('page-' + currentStep).classList.remove('active')
  currentStep = n
  document.getElementById('page-' + n).classList.add('active')
  updateStepper()
  updateFooter()
}

/**
 * Atualiza o visual do stepper (círculos e linhas) conforme passo atual.
 */
function updateStepper() {
  for (let i = 1; i <= 3; i++) {
    const circle = document.getElementById('circle-' + i)
    const label  = document.getElementById('label-' + i)
    circle.className = 'step-circle'
    label.className  = 'step-label'
    if (i < currentStep) {
      circle.classList.add('done'); circle.textContent = '✓'
      label.classList.add('done')
    } else if (i === currentStep) {
      circle.classList.add('active'); circle.textContent = i
      label.classList.add('active')
    } else {
      circle.textContent = i
    }
  }
  for (let i = 1; i <= 2; i++) {
    const line = document.getElementById('line-' + i)
    line.className = 'step-line' + (i < currentStep ? ' done' : '')
  }
}

/**
 * Atualiza o rodapé (footer) conforme passo atual e estado dos dados.
 * Habilita/desabilita botões e troca rótulos.
 */
function updateFooter() {
  const back    = document.getElementById('btn-back')
  const next    = document.getElementById('btn-next')
  back.style.display = currentStep > 1 ? 'block' : 'none'
  if (currentStep === 3) {
    next.textContent = '🗑 Confirmar Limpeza'
    next.classList.remove('btn-next', 'btn-delete')
    next.classList.add('btn-delete')
    next.onclick     = confirmDelete
    next.disabled    = true   // habilitado após scan
  } else {
    next.textContent = 'Próximo →'
    next.classList.remove('btn-next', 'btn-delete')
    next.classList.add('btn-next')
    next.onclick     = goNext
    next.disabled    = (currentStep === 1 && !selectedPath)
  }
}

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

/**
 * Reinicia o wizard para uma nova limpeza, resetando estado e UI.
 */
function resetWizard() {
  selectedPath = ''
  fileCount    = 0
  document.getElementById('folder-drop').style.display    = 'block'
  document.getElementById('folder-display').style.display = 'none'
  const status = document.getElementById('scan-status')
  status.textContent = '⏳ Escaneando arquivos...'
  status.className   = 'scan-status loading'
  const fileList = document.getElementById('file-list')
  fileList.style.display = 'none'
  fileList.innerHTML     = ''
  document.getElementById('btn-new-clean').style.display = 'none'
  document.getElementById('btn-next').style.display      = ''
  setStep(1)
}

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
