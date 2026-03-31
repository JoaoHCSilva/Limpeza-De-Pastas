// utils.js - Funções utilitárias de formatação e validação

/**
 * Formata um objeto Date para string ISO (yyyy-mm-dd) para campos <input type="date">.
 */
function formatDate(d) {
  return d.toISOString().split('T')[0]
}

/**
 * Formata data ISO (yyyy-mm-dd) para formato brasileiro (dd/mm/yyyy).
 */
function formatDateBR(iso) {
  const [y, m, d] = iso.split('-')
  return `${d}/${m}/${y}`
}
