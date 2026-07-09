import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navbar"
export default class extends Controller {
  static targets = ["icon"]

  connect() {
    this.collapse = document.getElementById("mainNavbar")
    if (!this.collapse) return

    this.showHandler = () => this.toggleIcon(true)
    this.hideHandler = () => this.toggleIcon(false)
    this.collapse.addEventListener("show.bs.collapse", this.showHandler)
    this.collapse.addEventListener("hide.bs.collapse", this.hideHandler)
  }

  disconnect() {
    if (!this.collapse) return
    this.collapse.removeEventListener("show.bs.collapse", this.showHandler)
    this.collapse.removeEventListener("hide.bs.collapse", this.hideHandler)
  }

  toggleIcon(isOpen) {
    this.iconTarget.classList.toggle("bi-list", !isOpen)
    this.iconTarget.classList.toggle("bi-x-lg", isOpen)
  }
}
