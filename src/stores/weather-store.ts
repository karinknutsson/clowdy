import { defineStore, acceptHMRUpdate } from "pinia";

const token = import.meta.env.VITE_OPENWEATHER_API_KEY;

export const useWeatherStore = defineStore("weatherStore", {
  state: () => ({}),
  getters: {},
  actions: {},
});

if (import.meta.hot) {
  import.meta.hot.accept(acceptHMRUpdate(useWeatherStore, import.meta.hot));
}
