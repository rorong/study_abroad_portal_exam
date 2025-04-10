import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["quoteText", "quoteAuthor", "searchInput", "suggestions"]

  connect() {
    console.log("Search Page Controller connected")
    this.quotes = [
      {
        text: "Education is the passport to the future, for tomorrow belongs to those who prepare for it today.",
        author: "Malcolm X"
      },
      {
        text: "The world is a book and those who do not travel read only one page.",
        author: "Saint Augustine"
      },
      {
        text: "Study abroad is the single most effective way of changing the way we view the world.",
        author: "Chantal Mitchell"
      },
      {
        text: "Travel is the only thing you buy that makes you richer.",
        author: "Anonymous"
      }
    ]

    this.currentQuoteIndex = 0
    this.startQuoteRotation()
  }

  disconnect() {
    if (this.quoteInterval) {
      clearInterval(this.quoteInterval)
    }
  }

  startQuoteRotation() {
    this.updateQuote()
    this.quoteInterval = setInterval(() => this.updateQuote(), 5000)
  }

  updateQuote() {
    this.quoteTextTarget.classList.remove('visible')
    this.quoteAuthorTarget.classList.remove('visible')

    setTimeout(() => {
      this.quoteTextTarget.textContent = this.quotes[this.currentQuoteIndex].text
      this.quoteAuthorTarget.textContent = `- ${this.quotes[this.currentQuoteIndex].author}`
      this.quoteTextTarget.classList.add('visible')
      this.quoteAuthorTarget.classList.add('visible')
    }, 500)

    this.currentQuoteIndex = (this.currentQuoteIndex + 1) % this.quotes.length
  }

  showSuggestions() {
    this.suggestionsTarget.classList.add('visible')
  }

  hideSuggestions() {
    setTimeout(() => {
      this.suggestionsTarget.classList.remove('visible')
    }, 200)
  }

  handleSuggestionClick(event) {
    const suggestionText = event.currentTarget.querySelector('.suggestion-text').textContent
    this.searchInputTarget.value = suggestionText
    this.suggestionsTarget.classList.remove('visible')
    // Trigger search
    document.querySelector('button[data-action="search#performSearch"]').click()
  }
} 