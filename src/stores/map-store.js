import { set } from "@vueuse/core";
import { defineStore, acceptHMRUpdate } from "pinia";

export const useMapStore = defineStore("mapStore", {
  state: () => ({
    lng: 13.38886,
    lat: 52.517037,
    zoom: 6,
  }),
  getters: {},
  actions: {
    setCoordinates(lng, lat) {
      set(this, "lng", lng);
      set(this, "lat", lat);
    },

    setZoom(zoom) {
      set(this, "zoom", zoom);
    },
  },
});

if (import.meta.hot) {
  import.meta.hot.accept(acceptHMRUpdate(useMapStore, import.meta.hot));
}
