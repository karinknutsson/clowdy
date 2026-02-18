import { set } from "@vueuse/core";
import { defineStore, acceptHMRUpdate } from "pinia";

export const useMapStore = defineStore("mapStore", {
  state: () => ({
    lng: -92.90233378309256,
    lat: 15.52248385029769,
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
