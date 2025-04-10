import { Controller } from "@hotwired/stimulus"

export default class MapSearchController extends Controller {
  static targets = ["input", "form", "autocomplete", "map"]
  static values = {
    universities: Array
  }

  connect() {
    console.log("Map search controller connected")
    this.initializeGoogleMaps()
  }

  disconnect() {
    // Clean up when the controller is disconnected
    if (window.markers) {
      window.markers.forEach(marker => marker.setMap(null))
      window.markers = []
    }
    if (window.markerCluster) {
      window.markerCluster.clearMarkers()
      window.markerCluster = null
    }
    if (window.infoWindow) {
      window.infoWindow.close()
      window.infoWindow = null
    }
  }

  initializeGoogleMaps() {
    // Wait for Google Maps to be ready
    if (typeof google !== 'undefined' && google.maps) {
      this.initializeMap()
      this.initializePlacesAutocomplete()
    } else {
      window.addEventListener('google-maps-ready', () => {
        this.initializeMap()
        this.initializePlacesAutocomplete()
      })
    }
  }

  initializeMap() {
    try {
      // Get URL parameters
      const urlParams = new URLSearchParams(window.location.search)
      const lat = urlParams.get('lat') ? parseFloat(urlParams.get('lat')) : null
      const lng = urlParams.get('lng') ? parseFloat(urlParams.get('lng')) : null

      // Initialize the map
      window.map = new google.maps.Map(this.mapTarget, {
        zoom: lat && lng ? 10 : 2,
        center: lat && lng ? 
          { lat: lat, lng: lng } : 
          { lat: 20, lng: 0 },
        mapTypeId: 'terrain',
        minZoom: 2
      })

      // Initialize info window
      window.infoWindow = new google.maps.InfoWindow()
      window.markers = []

      // Add markers for initial universities
      if (this.universitiesValue && this.universitiesValue.length > 0) {
        this.addMarkersToMap(this.universitiesValue)
      }
    } catch (error) {
      console.error('Error initializing map:', error)
    }
  }

  addMarkersToMap(universities) {
    try {
      // Clear existing markers
      if (window.markers) {
        window.markers.forEach(marker => marker.setMap(null))
        window.markers = []
      }

      if (!universities || !Array.isArray(universities)) {
        console.error('Invalid universities data:', universities)
        return
      }

      universities.forEach(university => {
        if (university.latitude && university.longitude) {
          const lat = parseFloat(university.latitude)
          const lng = parseFloat(university.longitude)

          // Validate coordinates
          if (isNaN(lat) || isNaN(lng) || lat < -90 || lat > 90 || lng < -180 || lng > 180) {
            console.warn('Invalid coordinates for university:', university.name, lat, lng)
            return
          }

          const position = {
            lat: lat,
            lng: lng
          }

          const marker = new google.maps.Marker({
            position: position,
            map: window.map,
            title: university.name,
            animation: google.maps.Animation.DROP
          })

          marker.addListener('click', () => {
            if (window.infoWindow) {
              window.infoWindow.close()
            }

            const content = `
              <div class="p-2">
                <h5 class="mb-2">${university.name}</h5>
                <p class="mb-1"><strong>Country:</strong> ${university.country || 'N/A'}</p>
                <p class="mb-1"><strong>Type:</strong> ${university.type_of_university || 'N/A'}</p>
                <p class="mb-1"><strong>Address:</strong> ${university.address || 'N/A'}</p>
                <a href="/universities/${university.id}" class="btn btn-primary btn-sm mt-2 w-100" data-turbo="false">
                  View Details
                </a>
              </div>
            `

            window.infoWindow.setContent(content)
            window.infoWindow.open(window.map, marker)

            window.map.setCenter(marker.getPosition())
            window.map.setZoom(15)
          })

          window.markers.push(marker)
        }
      })

      // Initialize clustering if we have markers
      if (window.markers && window.markers.length > 0) {
        if (window.markerCluster) {
          window.markerCluster.clearMarkers()
        }

        window.markerCluster = new MarkerClusterer(window.map, window.markers, {
          gridSize: 60,
          maxZoom: 15,
          minimumClusterSize: 2,
          imagePath: 'https://developers.google.com/maps/documentation/javascript/examples/markerclusterer/m',
          styles: [
            {
              textColor: 'black',
              url: 'https://developers.google.com/maps/documentation/javascript/examples/markerclusterer/m1.png',
              height: 53,
              width: 53,
              textSize: 16,
              fontWeight: 'bold',
              anchorText: [27, 27],
              anchorIcon: [27, 27]
            },
            {
              textColor: 'black',
              url: 'https://developers.google.com/maps/documentation/javascript/examples/markerclusterer/m2.png',
              height: 56,
              width: 56,
              textSize: 16,
              fontWeight: 'bold',
              anchorText: [28, 28],
              anchorIcon: [28, 28]
            },
            {
              textColor: 'black',
              url: 'https://developers.google.com/maps/documentation/javascript/examples/markerclusterer/m3.png',
              height: 66,
              width: 66,
              textSize: 16,
              fontWeight: 'bold',
              anchorText: [33, 33],
              anchorIcon: [33, 33]
            }
          ]
        })

        // Fit bounds to show all markers
        const bounds = new google.maps.LatLngBounds()
        window.markers.forEach(marker => bounds.extend(marker.getPosition()))
        window.map.fitBounds(bounds)

        // Handle zoom level based on search parameters
        const urlParams = new URLSearchParams(window.location.search)
        const lat = urlParams.get('lat') ? parseFloat(urlParams.get('lat')) : null
        const lng = urlParams.get('lng') ? parseFloat(urlParams.get('lng')) : null
        
        if (lat && lng) {
          window.map.setCenter({ lat: lat, lng: lng })
          window.map.setZoom(10)
        } else if (window.map.getZoom() > 15) {
          window.map.setZoom(15)
        }
      }
    } catch (error) {
      console.error('Error adding markers to map:', error)
    }
  }

  initializePlacesAutocomplete() {
    const input = this.inputTarget
    
    // Initialize Google Places Autocomplete with worldwide suggestions
    const autocomplete = new google.maps.places.Autocomplete(input, {
      types: ['establishment', 'geocode']
    })

    // Handle place selection
    autocomplete.addListener('place_changed', () => {
      const place = autocomplete.getPlace()
      if (place.geometry) {
        // Update form with selected location
        input.value = place.formatted_address
        
        // Add hidden fields for lat/lng
        let latInput = document.getElementById('lat')
        let lngInput = document.getElementById('lng')
        
        if (!latInput) {
          latInput = document.createElement('input')
          latInput.type = 'hidden'
          latInput.id = 'lat'
          latInput.name = 'lat'
          this.formTarget.appendChild(latInput)
        }
        
        if (!lngInput) {
          lngInput = document.createElement('input')
          lngInput.type = 'hidden'
          lngInput.id = 'lng'
          lngInput.name = 'lng'
          this.formTarget.appendChild(lngInput)
        }
        
        latInput.value = place.geometry.location.lat()
        lngInput.value = place.geometry.location.lng()
        
        // Perform search with new coordinates
        this.performSearch()
      }
    })
  }

  performSearch() {
    const form = this.formTarget
    if (!form) return

    const formData = new FormData(form)
    
    // Update URL with search parameters
    const searchParams = new URLSearchParams(formData)
    const url = `${window.location.pathname}?${searchParams.toString()}`
    
    // Update browser URL without reloading
    window.history.pushState({}, '', url)
    
    // Show loading state
    const listContainer = document.querySelector('.list-group.list-group-flush')
    if (listContainer) {
      listContainer.innerHTML = '<div class="text-center p-4"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div></div>'
    }
    
    // Fetch updated results
    fetch(url, {
      headers: {
        "Accept": "application/json"
      }
    })
    .then(response => response.json())
    .then(data => {
      // Update the list of universities
      this.updateUniversityList(data.universities)
      
      // Update the map markers
      this.addMarkersToMap(data.universities)
      
      // Update the count
      const countElement = document.querySelector('.h5.mb-3')
      if (countElement) {
        countElement.textContent = `Universities (${data.total_count})`
      }
    })
    .catch(error => {
      console.error('Error:', error)
      // Show error message
      if (listContainer) {
        listContainer.innerHTML = '<div class="alert alert-danger m-3">Error loading universities. Please try again.</div>'
      }
    })
  }

  updateUniversityList(universities) {
    const listContainer = document.querySelector('.list-group.list-group-flush')
    if (!listContainer) return

    if (universities.length === 0) {
      listContainer.innerHTML = '<div class="text-center p-4 text-muted">No universities found within 50km of this location.</div>'
      return
    }

    listContainer.innerHTML = universities.map(university => `
      <div class="list-group-item list-group-item-action" 
           data-lat="${university.latitude}" 
           data-lng="${university.longitude}"
           data-action="click->map-search#focusUniversity">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h5 class="mb-1">${university.name}</h5>
            <p class="mb-1 text-muted">
              <i class="fas fa-map-marker-alt me-1"></i>
              ${[university.city, university.country].filter(Boolean).join(", ")}
            </p>
          </div>
          <div class="text-end">
            ${university.world_ranking ? `<span class="badge bg-primary mb-1">World Rank: ${university.world_ranking}</span>` : ''}
            ${university.qs_ranking ? `<span class="badge bg-success">QS Rank: ${university.qs_ranking}</span>` : ''}
          </div>
        </div>
      </div>
    `).join('')
  }

  focusUniversity(event) {
    const item = event.currentTarget
    const lat = parseFloat(item.dataset.lat)
    const lng = parseFloat(item.dataset.lng)
    
    // Remove active class from all items
    document.querySelectorAll('.list-group-item').forEach(el => {
      el.classList.remove('active')
    })
    
    // Add active class to clicked item
    item.classList.add('active')
    
    // Center map on university
    if (window.map && lat && lng) {
      window.map.setCenter({ lat, lng })
      window.map.setZoom(15)
      
      // Find and click the corresponding marker
      window.markers.forEach(marker => {
        if (marker.getPosition().lat() === lat && marker.getPosition().lng() === lng) {
          google.maps.event.trigger(marker, 'click')
        }
      })
    }
  }
} 