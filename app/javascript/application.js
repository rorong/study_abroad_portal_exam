// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "jquery"
import "bootstrap"
import "@popperjs/core"

// Make jQuery available globally
window.jQuery = window.$ = jQuery;
