// app/javascript/controllers/order_items_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    console.log("Order items controller connected")
    // Используем более простой способ генерации индексов
    this.updateIndex()
  }

  updateIndex() {
    // Находим все существующие поля и определяем следующий индекс
    const existingFields = this.containerTarget.querySelectorAll('.nested-fields')
    this.index = existingFields.length
    console.log("Current index:", this.index)
  }

  add(event) {
    event.preventDefault()
    console.log("Add method called, current index:", this.index)
    
    const template = document.querySelector("#order-item-template")
    if (!template) {
      console.error("Template not found")
      return
    }
    
    // Создаем уникальный индекс на основе времени
    const uniqueIndex = new Date().getTime()
    
    // Заменяем INDEX на уникальный индекс
    let htmlContent = template.innerHTML.replace(/INDEX/g, uniqueIndex)
    
    // Создаем новый элемент
    const tempDiv = document.createElement('div')
    tempDiv.innerHTML = htmlContent.trim()
    const newRow = tempDiv.firstElementChild
    
    if (newRow) {
      this.containerTarget.appendChild(newRow)
      console.log("New row added with index:", uniqueIndex)
      this.updateIndex()
    } else {
      console.error("Failed to create new row")
    }
  }

  remove(event) {
    event.preventDefault()
    console.log("Remove method called")
    
    const field = event.target.closest(".nested-fields")
    if (!field) {
      console.error("Could not find nested-fields container")
      return
    }
    
    const destroyInput = field.querySelector("input[name*='_destroy']")
    
    if (destroyInput) {
      // Проверяем, есть ли у элемента ID (существующий элемент)
      const idInput = field.querySelector("input[name*='[id]']")
      
      if (idInput && idInput.value) {
        // Существующий элемент - помечаем на удаление
        console.log("Marking existing item for destruction")
        destroyInput.value = "1"
        field.style.display = "none"
        field.classList.add('marked-for-destruction')
      } else {
        // Новый элемент - просто удаляем
        console.log("Removing new item from DOM")
        field.remove()
        this.updateIndex()
      }
    } else {
      // Нет поля _destroy - просто удаляем
      console.log("No destroy field found, removing from DOM")
      field.remove()
      this.updateIndex()
    }
  }
}