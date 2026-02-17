import { defineStore, acceptHMRUpdate } from "pinia";

const token = import.meta.env.VITE_OPENWEATHER_API_KEY;

export const useWeatherStore = defineStore("weatherStore", {
  state: () => ({
    airTemp: "",
    feelsLikeTemp: "",
    feelsLikeDescription: "",
    windSpeed: "",
    windSpeedDescription: "",
    location: "",
  }),
  getters: {},
  actions: {
    setAirTemp(temp) {
      this.airTemp = temp;
    },

    setFeelsLike(temp) {
      this.feelsLikeTemp = temp;

      if (temp <= -5) {
        this.feelsLikeDescription = "Icy";
      } else if (temp <= 4) {
        this.feelsLikeDescription = "Harsh";
      } else if (temp <= 9) {
        this.feelsLikeDescription = "Chilly";
      } else if (temp <= 15) {
        this.feelsLikeDescription = "Cool";
      } else if (temp <= 21) {
        this.feelsLikeDescription = "Mild";
      } else if (temp <= 26) {
        this.feelsLikeDescription = "Warm";
      } else if (temp <= 31) {
        this.feelsLikeDescription = "Hot";
      } else {
        this.feelsLikeDescription = "Blazing";
      }
    },

    setWindSpeed(speed) {
      this.windSpeed = speed;

      if (speed <= 5) {
        this.windDescription = "Calm";
      } else if (speed <= 19) {
        this.windDescription = "Breezy";
      } else if (speed <= 39) {
        this.windDescription = "Windy";
      } else if (speed <= 59) {
        this.windDescription = "Strong";
      } else if (speed <= 89) {
        this.windDescription = "Gale";
      } else {
        this.windDescription = "Storm";
      }
    },

    setLocation(location) {
      this.location = location;
    },

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
