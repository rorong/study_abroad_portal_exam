import { Controller } from "@hotwired/stimulus";

export default class SearchController extends Controller {
  static targets = ["input", "queryResults", "queryText", "courseCount", "resultsContainer", "form", 
                    "minDuration", "maxDuration", "durationSlider",
                    "minApplicationFee", "maxApplicationFee", "applicationFeeSlider",
                    "minInternship", "maxInternship", "internshipSlider",
                    "minWorldRanking", "maxWorldRanking", "worldRankingSlider",
                    "minQsRanking", "maxQsRanking", "qsRankingSlider",
                    "minNationalRanking", "maxNationalRanking", "nationalRankingSlider",
                    "minTuitionFee", "maxTuitionFee", "tuitionFeeSlider",
                    "addressInput", "latitude", "longitude", "addressError",
                    "distance", "distanceSlider", "perPage"];

  static values = {
    currency: String
  }

  connect() {
    console.log("Search controller connected!");
    this.timeout = null;
    this.searchTimeout = null;
    this.autocomplete = null;
    
    // Initialize currency from data attribute or value
    this.currency = this.currencyValue || this.element.dataset.currency || 'USD';
    console.log("Initialized currency:", this.currency);
    
    // Initialize exchange rates
    this.exchangeRates = {
      'USD': 1.0,
      'CAD': 1.37,
      'INR': 83.12,
      'GBP': 0.79
    };
    
    // Fetch exchange rates from server
    this.fetchExchangeRates();
    
    // Add click outside listener only if queryResults target exists
    if (this.hasQueryResultsTarget) {
      document.addEventListener('click', (event) => {
        if (!this.element.contains(event.target)) {
          this.queryResultsTarget.classList.add('d-none');
        }
      });
    }

    // Initialize all sliders
    this.initializeSliders();

    // Initialize Google Places Autocomplete if address input exists
    if (this.hasAddressInputTarget) {
      this.initializeGooglePlaces();
    }
    
    // Listen for currency changes
    document.addEventListener('currency:updated', (event) => {
      if (event.detail && event.detail.currency) {
        this.currency = event.detail.currency;
        console.log("Currency updated to:", this.currency);
        this.currencyValue = this.currency;
        this.initializeSliders();
        
        // Force a page reload to ensure all currency displays are updated
        window.location.reload();
      }
    });
  }

  fetchExchangeRates() {
    fetch('/exchange_rates')
      .then(response => {
        if (response.ok) {
          return response.json();
        }
        throw new Error('Failed to fetch exchange rates');
      })
      .then(data => {
        this.exchangeRates = data;
        console.log('Exchange rates updated:', this.exchangeRates);
        
        // Reinitialize sliders with new exchange rates
        this.initializeSliders();
      })
      .catch(error => {
        console.error('Error fetching exchange rates:', error);
        // Keep using the default hardcoded rates
      });
  }

  initializeSliders() {
    // Initialize duration slider if it exists
    if (this.hasDurationSliderTarget) {
      this.initializeDurationSlider();
    }

    // Initialize tuition fee slider
    if (this.hasTuitionFeeSliderTarget) {
      const slider = this.tuitionFeeSliderTarget;
      const maxInput = this.maxTuitionFeeTarget;
      
      // Only set the slider value if the input already has a value
      if (maxInput.value) {
        slider.value = maxInput.value;
      }
    }

    // Initialize application fee slider
    if (this.hasApplicationFeeSliderTarget) {
      const slider = this.applicationFeeSliderTarget;
      const maxInput = this.maxApplicationFeeTarget;
      
      // Only set the slider value if the input already has a value
      if (maxInput.value) {
        slider.value = maxInput.value;
      }
    }

    // Initialize internship slider if it exists
    if (this.hasInternshipSliderTarget) {
      this.initializeInternshipSlider();
    }

    // Initialize world ranking slider if it exists
    if (this.hasWorldRankingSliderTarget) {
      this.initializeWorldRankingSlider();
    }

    // Initialize QS ranking slider if it exists
    if (this.hasQsRankingSliderTarget) {
      this.initializeQsRankingSlider();
    }

    // Initialize national ranking slider if it exists
    if (this.hasNationalRankingSliderTarget) {
      this.initializeNationalRankingSlider();
    }
    
    // Initialize distance slider if it exists
    if (this.hasDistanceSliderTarget) {
      this.initializeDistanceSlider();
    }
  }

  initializeDurationSlider() {
    const slider = this.durationSliderTarget;
    const minInput = this.minDurationTarget;
    const maxInput = this.maxDurationTarget;

    // Set initial values
    if (minInput.value) {
      slider.min = minInput.value;
    }
    if (maxInput.value) {
      slider.value = maxInput.value;
    }
  }

  initializeApplicationFeeSlider() {
    const slider = this.applicationFeeSliderTarget;
    const minInput = this.minApplicationFeeTarget;
    const maxInput = this.maxApplicationFeeTarget;

    // Set initial values
    if (minInput.value) {
      slider.min = minInput.value;
    }
    if (maxInput.value) {
      slider.value = maxInput.value;
    }
  }

  initializeInternshipSlider() {
    const slider = this.internshipSliderTarget;
    const minInput = this.minInternshipTarget;
    const maxInput = this.maxInternshipTarget;

    // Set initial values
    if (minInput.value) {
      slider.min = minInput.value;
    }
    if (maxInput.value) {
      slider.value = maxInput.value;
    }
  }

  initializeWorldRankingSlider() {
    const slider = this.worldRankingSliderTarget;
    const minInput = this.minWorldRankingTarget;
    const maxInput = this.maxWorldRankingTarget;

    // Set initial values
    if (minInput.value) {
      slider.min = minInput.value;
    }
    if (maxInput.value) {
      slider.value = maxInput.value;
    }
  }

  initializeQsRankingSlider() {
    const slider = this.qsRankingSliderTarget;
    const minInput = this.minQsRankingTarget;
    const maxInput = this.maxQsRankingTarget;

    // Set initial values
    if (minInput.value) {
      slider.min = minInput.value;
    }
    if (maxInput.value) {
      slider.value = maxInput.value;
    }
  }

  initializeNationalRankingSlider() {
    const slider = this.nationalRankingSliderTarget;
    const minInput = this.minNationalRankingTarget;
    const maxInput = this.maxNationalRankingTarget;

    // Set initial values
    if (minInput.value) {
      slider.min = minInput.value;
    }
    if (maxInput.value) {
      slider.value = maxInput.value;
    }
  }

  initializeTuitionFeeSlider() {
    const slider = this.tuitionFeeSliderTarget;
    const minInput = this.minTuitionFeeTarget;
    const maxInput = this.maxTuitionFeeTarget;

    // Set initial values
    if (minInput.value) {
      slider.min = minInput.value;
    }
    if (maxInput.value) {
      slider.value = maxInput.value;
    }
  }

  initializeDistanceSlider() {
    const slider = this.distanceSliderTarget;
    const input = this.distanceTarget;

    // Only set the slider value if the input already has a value
    if (input.value) {
      slider.value = input.value;
    }
  }

  initializeGooglePlaces() {
    // Function to initialize Google Places
    const initPlaces = () => {
      try {
        console.log('Initializing Google Places...');
        
        if (!window.google || !window.google.maps) {
          console.error('Google Maps API not loaded');
          this.showAddressError('Google Maps API is not available');
          return;
        }

        if (!window.google.maps.places) {
          console.error('Google Places API not loaded');
          this.showAddressError('Google Places API is not available');
          return;
        }

        const input = this.addressInputTarget;
        console.log('Found address input:', input);
        
        // Initialize autocomplete with no country restrictions
        this.autocomplete = new google.maps.places.Autocomplete(input, {
          types: ['address']
          // Removed componentRestrictions to allow all countries
        });
        console.log('Google Places Autocomplete initialized');

        // Add place_changed listener
        this.autocomplete.addListener('place_changed', () => {
          console.log('Place changed event triggered');
          const place = this.autocomplete.getPlace();
          console.log('Selected place:', place);
          
          if (place.geometry) {
            // Update hidden fields with lat/lng
            this.latitudeTarget.value = place.geometry.location.lat();
            this.longitudeTarget.value = place.geometry.location.lng();
            
            // Store the formatted address temporarily
            const addressInput = this.addressInputTarget;
            addressInput.value = place.formatted_address;
            
            // Clear any error message
            this.clearAddressError();
            
            // Trigger search
            this.search({ target: input });
          } else {
            console.error('Selected place has no geometry');
            this.showAddressError('Selected location is not valid');
          }
        });

        // Style the autocomplete dropdown
        const pacContainer = document.querySelector('.pac-container');
        if (pacContainer) {
          pacContainer.style.zIndex = '1050';
          console.log('Styled autocomplete dropdown');
        } else {
          console.warn('Could not find pac-container element');
        }
      } catch (error) {
        console.error('Error initializing Google Places:', error);
        this.showAddressError('Error initializing address search');
      }
    };

    // Check if Google Maps is already loaded
    if (window.google && window.google.maps) {
      console.log('Google Maps already loaded, initializing Places...');
      initPlaces();
    } else {
      console.log('Waiting for Google Maps to load...');
      // Wait for Google Maps to load
      window.addEventListener('google-maps-loaded', () => {
        console.log('Google Maps loaded event received, initializing Places...');
        initPlaces();
      });
    }
  }

  showAddressError(message) {
    const errorElement = this.element.querySelector('[data-search-target="addressError"]');
    if (errorElement) {
      errorElement.textContent = message;
      errorElement.style.display = 'block';
    }
  }

  clearAddressError() {
    const errorElement = this.element.querySelector('[data-search-target="addressError"]');
    if (errorElement) {
      errorElement.style.display = 'none';
    }
  }

  updateDurationInputs(event) {
    const slider = event.target;
    const maxInput = this.maxDurationTarget;
    const minInput = this.minDurationTarget;

    // Update max duration input with slider value
    maxInput.value = slider.value;
    
    // If min duration is greater than max, update min to match max
    if (parseInt(minInput.value) > parseInt(maxInput.value)) {
      minInput.value = maxInput.value;
    }

    // Trigger search
    this.search(event);
  }

  updateApplicationFeeInputs(event) {
    const slider = event.target;
    const maxInput = this.maxApplicationFeeTarget;
    const minInput = this.minApplicationFeeTarget;

    // Update max application fee input with slider value
    maxInput.value = slider.value;
    
    // If min application fee is greater than max, update min to match max
    if (parseInt(minInput.value) > parseInt(maxInput.value)) {
      minInput.value = maxInput.value;
    }

    // Trigger search with explicit flag
    this.search(event);
  }

  updateInternshipInputs(event) {
    const slider = event.target;
    const maxInput = this.maxInternshipTarget;
    const minInput = this.minInternshipTarget;

    // Update max internship input with slider value
    maxInput.value = slider.value;
    
    // If min internship is greater than max, update min to match max
    if (parseInt(minInput.value) > parseInt(maxInput.value)) {
      minInput.value = maxInput.value;
    }

    // Trigger search
    this.search(event);
  }

  updateWorldRankingInputs(event) {
    const slider = event.target;
    const maxInput = this.maxWorldRankingTarget;
    const minInput = this.minWorldRankingTarget;

    // Update max world ranking input with slider value
    maxInput.value = slider.value;
    
    // If min world ranking is greater than max, update min to match max
    if (parseInt(minInput.value) > parseInt(maxInput.value)) {
      minInput.value = maxInput.value;
    }

    // Trigger search
    this.search(event);
  }

  updateQsRankingInputs(event) {
    const slider = event.target;
    const maxInput = this.maxQsRankingTarget;
    const minInput = this.minQsRankingTarget;

    // Update max QS ranking input with slider value
    maxInput.value = slider.value;
    
    // If min QS ranking is greater than max, update min to match max
    if (parseInt(minInput.value) > parseInt(maxInput.value)) {
      minInput.value = maxInput.value;
    }

    // Trigger search
    this.search(event);
  }

  updateNationalRankingInputs(event) {
    const slider = event.target;
    const maxInput = this.maxNationalRankingTarget;
    const minInput = this.minNationalRankingTarget;

    // Update max national ranking input with slider value
    maxInput.value = slider.value;
    
    // If min national ranking is greater than max, update min to match max
    if (parseInt(minInput.value) > parseInt(maxInput.value)) {
      minInput.value = maxInput.value;
    }

    // Trigger search
    this.search(event);
  }

  updateTuitionFeeInputs(event) {
    const slider = event.target;
    const maxInput = this.maxTuitionFeeTarget;
    const minInput = this.minTuitionFeeTarget;

    // Update max tuition fee input with slider value
    maxInput.value = slider.value;
    
    // If min tuition fee is greater than max, update min to match max
    if (parseInt(minInput.value) > parseInt(maxInput.value)) {
      minInput.value = maxInput.value;
    }

    // Trigger search with explicit flag
    this.search(event);
  }

  updateDistanceInputs(event) {
    const slider = event.target;
    const input = this.distanceTarget;

    // Update distance input with slider value
    input.value = slider.value;
    
    // Trigger search with explicit flag
    this.search(event);
  }

  handleFilterChange(event) {
    console.log("Filter changed:", event.target.name, event.target.value);
    
    // Find the closest form element
    const form = event.target.closest('form');
    if (!form) {
      console.error("No form found for filter change");
      return;
    }
    
    // Get current URL parameters
    const urlParams = new URLSearchParams(window.location.search);
    const formData = new FormData(form);
    const newParams = new URLSearchParams();
    
    // Preserve existing parameters that aren't in the form
    for (const [key, value] of urlParams.entries()) {
      if (!formData.has(key)) {
        newParams.append(key, value);
      }
    }
    
    // Add form data
    for (const [key, value] of formData.entries()) {
      if (value) {
        newParams.set(key, value);
      }
    }
    
    // Ensure query parameter is preserved if it exists
    if (urlParams.has('query') && !newParams.has('query')) {
      newParams.append('query', urlParams.get('query'));
    }
    
    // Submit form with Turbo
    const url = `${form.action}?${newParams.toString()}`;
    console.log("Submitting filter change to:", url);
    Turbo.visit(url, { action: "replace" });
  }

  search(event) {
    console.log("Searching...", event);
    clearTimeout(this.timeout);
    
    // Find the closest form element
    const form = event.target.closest('form');
    
    // Always update query results for search input if target exists
    if (event.target.matches('[data-search-target="input"]') && this.hasQueryResultsTarget) {
      this.updateQueryResults(event);
    }
    
    // Set timeout for form submission
    this.timeout = setTimeout(() => {
      if (form) {
        // Get current URL parameters
        const urlParams = new URLSearchParams(window.location.search);
        const formData = new FormData(form);
        const newParams = new URLSearchParams();
        
        // Preserve existing parameters that aren't in the form
        for (const [key, value] of urlParams.entries()) {
          if (!formData.has(key)) {
            newParams.append(key, value);
          }
        }
        
        // Add form data
        for (const [key, value] of formData.entries()) {
          if (value) {
            newParams.set(key, value);
          }
        }
        
        // Ensure query parameter is preserved if it exists
        if (urlParams.has('query') && !newParams.has('query')) {
          newParams.append('query', urlParams.get('query'));
        }
        
        // Submit form with Turbo
        const url = `${form.action}?${newParams.toString()}`;
        console.log("Submitting form to:", url);
        Turbo.visit(url, { action: "replace" });
      }
    }, 300);
  }

  updateQueryResults(event) {
    const query = event.target.value.trim();
    console.log("Updating query results for:", query);
    // Clear any existing timeout
    clearTimeout(this.searchTimeout);
    // Set a new timeout
    this.searchTimeout = setTimeout(() => {
      if (query.length > 0) {
        console.log("Showing results container");
        this.queryResultsTarget.classList.remove('d-none');
        console.log("Fetching results from:", `/courses/search?query=${encodeURIComponent(query)}`);
        fetch(`/courses/search?query=${encodeURIComponent(query)}`)
          .then(response => {
            console.log("Got response:", response);
            return response.json();
          })
          .then(data => {
            console.log("Got data:", data);
            this.displaySearchResults(data.courses);
          })
          .catch(error => {
            console.error("Error fetching results:", error);
          });
      } else {
        console.log("Hiding results container");
        this.queryResultsTarget.classList.add('d-none');
        if (this.hasResultsContainerTarget) {
          this.resultsContainerTarget.innerHTML = '';
        }
      }
    }, 300); // 300ms delay before making the API call
  }

  displaySearchResults(courses) {
    console.log("Displaying search results:", courses);
    if (!this.hasResultsContainerTarget) {
      console.log("No results container target found");
      return;
    }
    const resultsHtml = courses.map(([id, name, university]) => `
      <div class="p-2 border-bottom course-result" 
          data-course-id="${id}"
          data-action="click->search#selectCourse">
        <div class="fw-bold">${name}</div>
        <div class="small text-muted">${university}</div>
      </div>
    `).join('');
    console.log("Generated HTML:", resultsHtml);
    this.resultsContainerTarget.innerHTML = resultsHtml;
  }

  selectCourse(event) {
    const selectedName = event.currentTarget.querySelector('.fw-bold').textContent.trim();
    if (this.hasInputTarget) {
      this.inputTarget.value = selectedName;
    }
    if (this.hasQueryResultsTarget) {
      this.queryResultsTarget.classList.add('d-none');
    }
    // Submit the form with the selected course
    const form = this.element;
    if (form) {
      // Get current URL parameters to preserve values
      const urlParams = new URLSearchParams(window.location.search);
      
      // Create a new FormData object from the form
      const formData = new FormData(form);
      
      // Create a new URLSearchParams object
      const newParams = new URLSearchParams();
      
      // First, add all existing URL parameters to preserve them
      for (const [key, value] of urlParams.entries()) {
        // Skip parameters that will be explicitly set by the form
        if (formData.has(key)) {
          continue;
        }
        newParams.append(key, value);
      }
      
      // Then add all form data to the new params
      for (const [key, value] of formData.entries()) {
        if (value) {
          newParams.set(key, value);
        }
      }
      
      // Submit the form with the preserved parameters
      Turbo.visit(form.action + '?' + newParams.toString(), { action: "replace" });
    }
  }

  performSearch(event) {
    event.preventDefault();
    const query = this.inputTarget.value.trim();
    if (query.length > 0) {
      // Find the closest form element
      const form = this.element;
      
      // Get current URL parameters to preserve values
      const urlParams = new URLSearchParams(window.location.search);
      
      // Create a new FormData object from the form
      const formData = new FormData(form);
      
      // Create a new URLSearchParams object
      const newParams = new URLSearchParams();
      
      // First, add all existing URL parameters to preserve them
      for (const [key, value] of urlParams.entries()) {
        // Skip parameters that will be explicitly set by the form
        if (formData.has(key)) {
          continue;
        }
        newParams.append(key, value);
      }
      
      // Then add all form data to the new params
      for (const [key, value] of formData.entries()) {
        if (value) {
          newParams.set(key, value);
        }
      }
      
      // Submit the form with the preserved parameters
      Turbo.visit(form.action + '?' + newParams.toString(), { action: "replace" });
    }
  }

  clear(event) {
    event.preventDefault();
    // Clear the search input if it exists
    if (this.hasInputTarget) {
      this.inputTarget.value = '';
    }
    // Hide the results container
    if (this.hasQueryResultsTarget) {
      this.queryResultsTarget.classList.add('d-none');
    }
    // Clear the results container
    if (this.hasResultsContainerTarget) {
      this.resultsContainerTarget.innerHTML = '';
    }
  }

  handleAddressKeydown(event) {
    if (event.key === 'Enter') {
      event.preventDefault();
      // Only trigger search if we have a valid place selected
      if (this.latitudeTarget.value && this.longitudeTarget.value) {
        this.search(event);
      }
    }
  }

  handleSort(event) {
    event.preventDefault();
    const form = event.target.closest('form');
    if (form) {
      // Create a new FormData object from the form
      const formData = new FormData(form);
      
      // Get all current URL parameters
      const urlParams = new URLSearchParams(window.location.search);
      
      // Create a new URLSearchParams object
      const newParams = new URLSearchParams();
      
      // First, add all existing URL parameters to preserve them
      for (const [key, value] of urlParams.entries()) {
        // Skip the sort parameter as we'll set it explicitly
        if (key === 'sort') {
          continue;
        }
        newParams.append(key, value);
      }
      
      // Then add the sort parameter from the form
      if (formData.has('sort')) {
        newParams.set('sort', formData.get('sort'));
      }
      
      // Submit the form with the preserved parameters
      Turbo.visit(form.action + '?' + newParams.toString(), { action: "replace" });
    }
  }

  updatePerPage(event) {
    // Get the selected per_page value
    const perPage = this.perPageTarget.value;
    
    // Find the closest form element
    const form = event.target.closest('form');
    
    if (form) {
      // Get current URL parameters to preserve values
      const urlParams = new URLSearchParams(window.location.search);
      
      // Create a new URLSearchParams object
      const newParams = new URLSearchParams();
      
      // First, add all existing URL parameters to preserve them
      for (const [key, value] of urlParams.entries()) {
        // Skip the per_page parameter as we'll set it explicitly
        if (key === 'per_page') {
          continue;
        }
        newParams.append(key, value);
      }
      
      // Then add the per_page parameter
      newParams.set('per_page', perPage);
      
      // Submit the form with the preserved parameters
      Turbo.visit(form.action + '?' + newParams.toString(), { action: "replace" });
    }
  }

  convertCurrency(amount, fromCurrency, toCurrency) {
    // Convert to USD first if not already in USD
    const usdAmount = fromCurrency === 'USD' ? amount : amount / this.exchangeRates[fromCurrency];
    
    // Then convert to target currency
    const convertedAmount = usdAmount * this.exchangeRates[toCurrency];
    
    // Round to 2 decimal places
    return Math.round(convertedAmount * 100) / 100;
  }
}
 