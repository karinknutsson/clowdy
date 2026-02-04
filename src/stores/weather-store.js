import { defineStore, acceptHMRUpdate } from "pinia";

const token = import.meta.env.VITE_OPENWEATHER_API_KEY;

export const useWeatherStore = defineStore("weatherStore", {
  state: () => ({}),
  getters: {},
  actions: {
    async fetchWeatherData(lng, lat) {
      try {
        if (!token) return;

        const res = await fetch(
          `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lng}&units=Metric&appid=${token}`,
        );
        const data = await res.json();

        if (res.ok) {
          return data;
        } else {
          console.error("Failed to fetch weather data:", data.message || "Unknown error");
          return null;
        }
      } catch (err) {
        console.error("Error fetching weather data:", err);
        return null;
      }
    },
  },
});

if (import.meta.hot) {
  import.meta.hot.accept(acceptHMRUpdate(useWeatherStore, import.meta.hot));
}
