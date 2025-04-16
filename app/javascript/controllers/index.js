// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import SearchController from "controllers/search_controller"
import FiltersController from "controllers/filters_controller"
import MapSearchController from "controllers/map_search_controller"
import SearchPageController from "controllers/search_page_controller"
import CurrencyController from "controllers/currency_controller"
import DropdownController from "controllers/dropdown_controller"
eagerLoadControllersFrom("controllers", application)

application.register("search", SearchController)
application.register("filters", FiltersController)
application.register("map_search", MapSearchController)
application.register("search_page", SearchPageController)
application.register('currency', CurrencyController)
application.register("dropdown", DropdownController)