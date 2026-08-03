import { Controller } from "@hotwired/stimulus"

// Держит CSS-переменную --admin-navbar-height равной реальной высоте фиксированной шапки.
// От неё зависят отступ контента (.padding-layout) и позиция выезжающего меню (.sidebar),
// поэтому при переносе строк в шапке ничего не перекрывается и не остаётся щели.
export default class extends Controller {
  connect() {
    this.update = this.update.bind(this)
    this.update()

    window.addEventListener("resize", this.update)
    window.addEventListener("orientationchange", this.update)

    if (window.ResizeObserver) {
      this.observer = new ResizeObserver(this.update)
      this.observer.observe(this.element)
    }
  }

  disconnect() {
    window.removeEventListener("resize", this.update)
    window.removeEventListener("orientationchange", this.update)
    this.observer?.disconnect()
    document.documentElement.style.removeProperty("--admin-navbar-height")
  }

  update() {
    const height = Math.round(this.element.getBoundingClientRect().height)
    document.documentElement.style.setProperty("--admin-navbar-height", `${height}px`)
  }
}
