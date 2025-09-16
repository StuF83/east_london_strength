// app/javascript/controllers/workout_copy_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    id: Number,
    existingDatesUrl: String 
  }
  
  static targets = [ 
    "confirmation", 
    "form", 
    "dateField", 
    "selectedDate" 
  ]

  connect() {
    this.existingDates = []
    this.dateRange = null
    this.datePickerVisible = false
  }

  async showDatePicker(event) {
    event.preventDefault()
    
    if (this.datePickerVisible) {
      this.hideDatePicker()
      return
    }

    // Fetch existing dates if we haven't already
    if (this.existingDates.length === 0) {
      await this.fetchExistingDates()
    }

    this.createDatePickerPopup(event.target)
    this.datePickerVisible = true
  }

  async fetchExistingDates() {
    try {
      const response = await fetch(this.existingDatesUrlValue)
      const data = await response.json()
      
      this.existingDates = data.existing_dates
      this.dateRange = data.date_range
    } catch (error) {
      console.error('Failed to fetch existing dates:', error)
      // Continue with empty array - will just not show conflicts
    }
  }

  createDatePickerPopup(button) {
    // Remove any existing popup
    this.removeDatePickerPopup()

    const popup = document.createElement('div')
    popup.className = 'date-picker-popup'
    popup.innerHTML = this.buildDatePickerHTML()
    
    // Position popup relative to button
    document.body.appendChild(popup)
    this.positionPopup(popup, button)
    
    // Add event listeners
    this.addDatePickerListeners(popup)
    
    // Store reference for cleanup
    this.datePickerPopup = popup
    
    // Close popup when clicking outside
    setTimeout(() => {
      document.addEventListener('click', this.handleOutsideClick.bind(this))
    }, 0)
  }

  buildDatePickerHTML() {
    const today = new Date()
    const startDate = new Date(this.dateRange.start)
    const endDate = new Date(this.dateRange.end)
    
    return `
      <div class="date-picker-header">
        <h4>Copy workout to date:</h4>
        <button type="button" class="date-picker-close" data-action="close">×</button>
      </div>
      <div class="date-picker-content">
        <input type="date" 
               class="date-picker-input"
               min="${startDate.toISOString().split('T')[0]}"
               max="${endDate.toISOString().split('T')[0]}"
               data-action="date-selected" />
        <div class="date-picker-help">
          <small>Dates with existing workouts will be highlighted in red</small>
        </div>
      </div>
    `
  }

  positionPopup(popup, button) {
    const buttonRect = button.getBoundingClientRect()
    
    // Position below button, aligned to left edge
    let top = buttonRect.bottom + window.scrollY + 8
    let left = buttonRect.left + window.scrollX
    
    // Adjust if popup would go off screen
    const popupWidth = 280 // approximate width from CSS
    if (left + popupWidth > window.innerWidth) {
      left = window.innerWidth - popupWidth - 10
    }
    
    popup.style.position = 'absolute'
    popup.style.top = `${top}px`
    popup.style.left = `${left}px`
    popup.style.zIndex = '1000'
  }

  addDatePickerListeners(popup) {
    const dateInput = popup.querySelector('.date-picker-input')
    const closeBtn = popup.querySelector('.date-picker-close')
    
    dateInput.addEventListener('change', this.handleDateSelected.bind(this))
    closeBtn.addEventListener('click', this.hideDatePicker.bind(this))
    
    // Highlight existing workout dates as user types/selects
    dateInput.addEventListener('input', (e) => {
      const selectedDate = e.target.value
      if (selectedDate && this.existingDates.includes(selectedDate)) {
        e.target.classList.add('date-conflict')
      } else {
        e.target.classList.remove('date-conflict')
      }
    })
  }

  handleDateSelected(event) {
    const selectedDate = event.target.value
    
    if (!selectedDate) return
    
    // Check if date already has a workout
    if (this.existingDates.includes(selectedDate)) {
      alert(`A workout already exists for ${this.formatDate(selectedDate)}. Please choose a different date.`)
      return
    }
    
    // Hide date picker and show confirmation
    this.hideDatePicker()
    this.showConfirmation(selectedDate)
  }

  showConfirmation(dateString) {
    // Update hidden form field
    this.dateFieldTarget.value = dateString
    
    // Update display text
    this.selectedDateTarget.textContent = this.formatDate(dateString)
    
    // Show confirmation section
    this.confirmationTarget.style.display = 'block'
    
    // Smooth scroll to confirmation if needed
    this.confirmationTarget.scrollIntoView({ 
      behavior: 'smooth', 
      block: 'nearest' 
    })
  }

  cancel(event) {
    event.preventDefault()
    this.hideConfirmation()
  }

  hideConfirmation() {
    this.confirmationTarget.style.display = 'none'
    this.dateFieldTarget.value = ''
  }

  hideDatePicker() {
    this.removeDatePickerPopup()
    this.datePickerVisible = false
    document.removeEventListener('click', this.handleOutsideClick.bind(this))
  }

  removeDatePickerPopup() {
    if (this.datePickerPopup) {
      this.datePickerPopup.remove()
      this.datePickerPopup = null
    }
  }

  handleOutsideClick(event) {
    if (this.datePickerPopup && 
        !this.datePickerPopup.contains(event.target) && 
        !event.target.matches('[data-action*="workout-copy#showDatePicker"]')) {
      this.hideDatePicker()
    }
  }

  formatDate(dateString) {
    const date = new Date(dateString + 'T12:00:00') // Avoid timezone issues
    return date.toLocaleDateString('en-US', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
  }

  disconnect() {
    this.hideDatePicker()
    document.removeEventListener('click', this.handleOutsideClick.bind(this))
  }
}