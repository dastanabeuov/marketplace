import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navbar"
export default class extends Controller {
  static targets = ["icon"]

  connect() {
    this.collapse = document.getElementById("mainNavbar")

    if (this.collapse) {
      this.collapse.addEventListener("show.bs.collapse", this.toggleIcon.bind(this, true))
      this.collapse.addEventListener("hide.bs.collapse", this.toggleIcon.bind(this, false))
    }
  }

  toggleIcon(isOpen) {
    if (isOpen) {
      this.iconTarget.classList.remove("bi-list")
      this.iconTarget.classList.add("bi-x")
    } else {
      this.iconTarget.classList.remove("bi-x")
      this.iconTarget.classList.add("bi-list")
    }
  }
}
