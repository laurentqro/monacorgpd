import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="question-answer"
export default class extends Controller {
  static values = {
    responseId: Number,
    answerId: Number
  }

  connect() {
    this.responseId = this.element.closest('[data-response-id]')?.dataset.responseId
    this.questionId = this.element.dataset.questionId
    this.saveTimeout = null
  }

  save(event) {
    // Clear any pending save
    if (this.saveTimeout) {
      clearTimeout(this.saveTimeout)
    }

    // Debounce saves by 500ms
    this.saveTimeout = setTimeout(() => {
      this.performSave()
    }, 500)
  }

  async performSave() {
    if (!this.responseId || !this.questionId) {
      console.error("Missing response ID or question ID")
      return
    }

    const formData = new FormData()
    formData.append("answer[question_id]", this.questionId)
    formData.append("answer[response_id]", this.responseId)

    // Collect all inputs within this question
    const inputs = this.element.querySelectorAll('input[type="text"], textarea, input[type="radio"]:checked, input[type="checkbox"]:checked')

    inputs.forEach(input => {
      const name = input.name
      if (name) {
        // Extract the parameter name from the Rails-style name
        const match = name.match(/\[([^\]]+)\](?:\[\])?$/)
        if (match) {
          const paramName = match[1]
          formData.append(`answer[${paramName}]${name.endsWith('[]') ? '[]' : ''}`, input.value)
        }
      }
    })

    const url = this.answerIdValue
      ? `/gdpr/responses/${this.responseId}/answers/${this.answerIdValue}`
      : `/gdpr/responses/${this.responseId}/answers`

    const method = this.answerIdValue ? 'PATCH' : 'POST'

    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

      const response = await fetch(url, {
        method: method,
        headers: {
          'X-CSRF-Token': csrfToken,
          'Accept': 'application/json'
        },
        body: formData
      })

      const data = await response.json()

      if (data.success) {
        this.answerIdValue = data.answer_id
        this.showSaveIndicator()
      } else {
        console.error("Error saving answer:", data.errors)
        this.showErrorIndicator()
      }
    } catch (error) {
      console.error("Failed to save answer:", error)
      this.showErrorIndicator()
    }
  }

  showSaveIndicator() {
    // Visual feedback that answer was saved
    const indicator = this.element.querySelector('[data-save-indicator]') || this.createSaveIndicator()
    indicator.textContent = "✓ Saved"
    indicator.classList.add('text-green-600')
    indicator.classList.remove('text-red-600', 'text-gray-400')

    setTimeout(() => {
      indicator.classList.remove('text-green-600')
      indicator.classList.add('text-gray-400')
    }, 2000)
  }

  showErrorIndicator() {
    const indicator = this.element.querySelector('[data-save-indicator]') || this.createSaveIndicator()
    indicator.textContent = "✗ Error"
    indicator.classList.add('text-red-600')
    indicator.classList.remove('text-green-600', 'text-gray-400')
  }

  createSaveIndicator() {
    const indicator = document.createElement('span')
    indicator.setAttribute('data-save-indicator', '')
    indicator.className = 'text-xs text-gray-400 ml-2'

    const label = this.element.querySelector('label')
    if (label) {
      label.appendChild(indicator)
    }

    return indicator
  }
}
