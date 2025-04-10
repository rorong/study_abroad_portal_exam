import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tuitionFee", "applicationFee"]
  
  connect() {
    console.log("Currency controller connected")
  }

  toggleDropdown(event) {
    // Let Bootstrap handle the dropdown toggle
    const dropdown = new bootstrap.Dropdown(event.currentTarget)
    dropdown.toggle()
  }

  update(event) {
    // Prevent the default form submission
    event.preventDefault()
    
    // Get the currency from the button's parent form
    const form = event.target.closest('form')
    const currency = form.querySelector('input[name="currency"]').value
    
    console.log("Updating currency to:", currency)
    
    // Dispatch a custom event that other controllers can listen for
    const currencyEvent = new CustomEvent('currency:updated', {
      detail: { currency: currency },
      bubbles: true
    })
    
    document.dispatchEvent(currencyEvent)
    
    // Submit the form to update the server-side session
    form.submit()
  }
  
  // This method will be called when the currency is updated
  updateCurrencyDisplay(event) {
    if (event.detail && event.detail.currency) {
      const currency = event.detail.currency
      console.log("Currency display updated to:", currency)
      
      // Force a page reload to ensure all currency displays are updated
      window.location.reload()
    }
  }
} 