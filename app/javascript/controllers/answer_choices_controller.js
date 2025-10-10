import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="answer-choices"
export default class extends Controller {
  static targets = ["container", "template"]
  static values = {
    index: Number
  }

  connect() {
    // Initialize index from existing choices
    if (this.indexValue === 0) {
      this.indexValue = this.containerTarget.children.length
    }
  }

  add(event) {
    event.preventDefault()

    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, this.indexValue)
    this.containerTarget.insertAdjacentHTML("beforeend", content)
    this.indexValue++
  }

  remove(event) {
    event.preventDefault()

    const item = event.target.closest("[data-answer-choice-item]")

    // If this is an existing record, mark it for destruction
    const destroyInput = item.querySelector("input[name*='_destroy']")
    if (destroyInput) {
      destroyInput.value = "1"
      item.style.display = "none"
    } else {
      // If it's a new record, just remove it from the DOM
      item.remove()
    }
  }
}
