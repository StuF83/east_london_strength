import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["editor", "preview"]

  connect() {
    this.refresh()
    
    // Listen for Lexxy ready event
    this.element.addEventListener('lexxy:ready', () => {
      this.refresh()
    })
    
    // Fallback: try again after a delay
    setTimeout(() => this.refresh(), 200)
  }

  refresh() {
    const editor = this.editorTarget.querySelector('lexxy-editor')
    if (editor) {
      const htmlContent = editor.value || ""
      this.previewTarget.innerHTML = htmlContent
    } else {
      // If editor not ready, try again shortly
      setTimeout(() => this.refresh(), 50)
    }
  }
}