// Ленивая загрузка тяжёлых вендорных библиотек (jQuery ~285 КБ, DataTables ~377 КБ,
// Select2 ~157 КБ, Chart.js с CDN). Каждая грузится один раз и только тогда, когда
// на странице действительно есть соответствующий контроллер.

let jqueryPromise = null
let dataTablesPromise = null
let select2Promise = null
let chartPromise = null

export function loadJQuery() {
  jqueryPromise ||= import("jquery")
  return jqueryPromise
}

// DataTables и Select2 — UMD-плагины: на момент выполнения им нужен глобальный jQuery,
// поэтому импортируем строго последовательно.
export function loadDataTables() {
  dataTablesPromise ||= loadJQuery().then(() => import("datatables"))
  return dataTablesPromise
}

export function loadSelect2() {
  select2Promise ||= loadJQuery().then(() => import("select2"))
  return select2Promise
}

export function loadChart() {
  chartPromise ||= import("chart.js").then(({ Chart, registerables }) => {
    Chart.register(...registerables)
    return Chart
  })
  return chartPromise
}
