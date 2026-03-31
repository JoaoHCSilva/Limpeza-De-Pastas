// wizard.js - Responsável pela navegação e estado do wizard

let currentStep = 1
let selectedPath = ''
let fileCount = 0

/**
 * Avança para o próximo passo do wizard, validando dados conforme necessário.
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
 * Ativa o passo do wizard e atualiza UI dos steps e footer.
 */
function setStep(n) {
  document.getElementById('page-' + currentStep).classList.remove('active')
  currentStep = n
  document.getElementById('page-' + n).classList.add('active')
  updateStepper()
  updateFooter()
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
