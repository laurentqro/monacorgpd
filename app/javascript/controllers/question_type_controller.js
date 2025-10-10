import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="question-type"
export default class extends Controller {
  static targets = ["answerChoices", "questionType"]

  connect() {
    this.toggleAnswerChoices()
  }

  toggleAnswerChoices() {
    const questionType = this.questionTypeTarget.value
    const requiresChoices = ["single_choice", "multiple_choice", "yes_no"].includes(questionType)

    if (this.hasAnswerChoicesTarget) {
      this.answerChoicesTarget.style.display = requiresChoices ? "block" : "none"
    }
  }
}
