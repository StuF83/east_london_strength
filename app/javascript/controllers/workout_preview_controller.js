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
    if (!editor) {
      setTimeout(() => this.refresh(), 50)
      return
    }

    const htmlContent = editor.value || ""
    
    // Get form values
    const form = this.element.querySelector('form')
    if (!form) return
    
    const formData = new FormData(form)
    const title = formData.get('workout[title]') || ''
    const tags = formData.get('workout[tags]') || ''

    // Update each section individually
    this.updateWorkoutTitle(title)
    this.updateWorkoutContent(htmlContent)
    this.updateWorkoutTags(tags)
  }

  updateWorkoutTitle(title) {
    const titleElement = this.previewTarget.querySelector('.workout-title')
    if (titleElement) {
      if (title.trim()) {
        titleElement.textContent = title
        titleElement.parentElement.style.display = 'block'
      } else {
        titleElement.parentElement.style.display = 'none'
      }
    }
  }

  updateWorkoutContent(htmlContent) {
    const contentArea = this.previewTarget.querySelector('.workout-content')
    if (contentArea) {
      if (htmlContent.trim()) {
        contentArea.innerHTML = htmlContent
      } else {
        contentArea.innerHTML = '<p class="workout-empty-content">No workout content available.</p>'
      }
    }
  }

  updateWorkoutTags(tags) {
    let tagsFooter = this.previewTarget.querySelector('.workout-tags')
    
    if (tags.trim()) {
      // Create footer if it doesn't exist
      if (!tagsFooter) {
        const article = this.previewTarget.querySelector('.workout-display')
        if (article) {
          tagsFooter = document.createElement('footer')
          tagsFooter.className = 'workout-tags'
          article.appendChild(tagsFooter)
        }
      }
      
      if (tagsFooter) {
        // Build tags HTML
        let tagsHTML = '<span class="workout-tags__label">Focus:</span>'
        const tagArray = tags.split(',').map(tag => tag.trim()).filter(tag => tag)
        tagArray.forEach(tag => {
          tagsHTML += `<span class="workout-tag">${this.escapeHtml(tag)}</span>`
        })
        tagsFooter.innerHTML = tagsHTML
      }
    } else {
      // Remove footer if no tags
      if (tagsFooter) {
        tagsFooter.remove()
      }
    }
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
}