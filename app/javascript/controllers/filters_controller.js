import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("Filters controller connected!");
  }
  removeFilter(event) {
    event.preventDefault();
    const filterUrl = event.currentTarget.href;

    fetch(filterUrl, {
      headers: { "Turbo-Frame": "courses_list" },
    }).then(() => {
      Turbo.visit(filterUrl, { action: "replace" });
    });
  }
}
 