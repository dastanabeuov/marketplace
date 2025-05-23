import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["footer"]

  connect() {
    this.boundAdjustFooter = this.adjustFooter.bind(this)
    
    // Запускаем сразу
    this.adjustFooter()
    
    // И еще раз с задержкой для надежности
    setTimeout(() => this.adjustFooter(), 100)
    
    window.addEventListener("resize", this.boundAdjustFooter)
    
    // Добавляем события Turbo
    document.addEventListener("turbo:load", this.boundAdjustFooter)
    document.addEventListener("turbo:render", this.boundAdjustFooter)
  }

  disconnect() {
    window.removeEventListener("resize", this.boundAdjustFooter)
    document.removeEventListener("turbo:load", this.boundAdjustFooter)
    document.removeEventListener("turbo:render", this.boundAdjustFooter)
  }

  adjustFooter() {
    if (!this.hasFooterTarget) return
    
    const body = document.body
    const html = document.documentElement
    const contentHeight = Math.max(
      body.scrollHeight, body.offsetHeight,
      html.clientHeight, html.scrollHeight, html.offsetHeight
    )

    if (contentHeight <= window.innerHeight) {
      this.footerTarget.classList.add("fixed-bottom")
    } else {
      this.footerTarget.classList.remove("fixed-bottom")
    }
  }
}