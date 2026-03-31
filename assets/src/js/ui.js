// ui.js - Responsável por atualização visual do stepper, footer e informações auxiliares

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
 * Atualiza o texto informativo do período selecionado (quantidade de dias).
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
