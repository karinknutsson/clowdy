import { defineStore, acceptHMRUpdate } from "pinia";

const MAPBOX_SEARCHBOX_URL = "https://api.mapbox.com/search/searchbox/v1/suggest";
const token = import.meta.env.VITE_MAPBOX_API_KEY;

export const useSearchStore = defineStore("searchStore", {
  state: () => ({
    sessionToken: "",
    suggestions: [],
    selectedCoordinates: { lng: 0, lat: 0 },
    brandSuggestions: [],
    loading: false,
    error: null,
    isSearchOpen: false,
  }),

  actions: {
    async selectSuggestion(suggestion) {
      try {
        const encodedMapboxId = encodeURIComponent(suggestion.mapbox_id);
        const retrieveUrl = `https://api.mapbox.com/search/searchbox/v1/retrieve/${encodedMapboxId}?session_token=${this.sessionToken}&access_token=${token}`;
        const res = await fetch(retrieveUrl);
        const data = await res.json();
        this.selectedCoordinates.lng = data.features[0].geometry.coordinates[0];
        this.selectedCoordinates.lat = data.features[0].geometry.coordinates[1];
      } catch (err) {
        console.error("Failed to retrieve suggestion details:", err);
      }
    },

    async fetchSuggestions(query) {
      if (!query) {
        this.suggestions = [];
        return;
      }

      this.loading = true;
      this.error = null;

      try {
        if (!token) return;

        this.sessionToken = Math.random().toString(36).substring(2);

        const params = new URLSearchParams({
          q: query,
          access_token: token,
          language: "en",
          limit: "5",
          session_token: this.sessionToken,
          types: "country,region,district,place,city,locality,neighborhood,poi",
        });

        const res = await fetch(`${MAPBOX_SEARCHBOX_URL}?${params.toString()}`);
        const data = await res.json();

        if (res.ok) {
          this.suggestions = data.suggestions;
        } else {
          this.error = data.message || "Failed to fetch suggestions";
          this.suggestions = [];
        }
      } catch (err) {
        this.error = err?.message || "Search failed";
        this.suggestions = [];
      } finally {
        this.loading = false;
      }
    },
  },
});

if (import.meta.hot) {
  import.meta.hot.accept(acceptHMRUpdate(useSearchStore, import.meta.hot));
}
