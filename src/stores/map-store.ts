import { set } from "@vueuse/core";
import { defineStore, acceptHMRUpdate } from "pinia";

export const useMapStore = defineStore("mapStore", {
  state: () => ({
    lng: 13.407557,
    lat: 52.509237,
    zoom: 12,
  }),
  getters: {},
  actions: {
    setCoordinates(lng: number, lat: number) {
      set(this, "lng", lng);
      set(this, "lat", lat);
    },

    setZoom(zoom: number) {
      set(this, "zoom", zoom);
    },
  },
});

if (import.meta.hot) {
  import.meta.hot.accept(acceptHMRUpdate(useMapStore, import.meta.hot));
}
