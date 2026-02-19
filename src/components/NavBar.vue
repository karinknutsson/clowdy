<template>
  <div class="nav-container">
    <div class="temp-container weather-card">
      <div class="weather-description-wrapper-wrapper">
        <div class="weather-description-wrapper">
          {{ weatherStore.weatherType ? weatherStore.weatherType : "&nbsp;" }}
        </div>
        <div class="weather-description-wrapper">
          {{ weatherStore.airTemp ? "Air temp " + weatherStore.airTemp + "°" : "&nbsp;" }}
        </div>
        <div class="weather-description-wrapper">
          {{ weatherStore.windDescription ? weatherStore.windDescription + " wind" : "&nbsp;" }}
        </div>
      </div>
      <div class="feels-like-container">
        <div class="feels-like-wrapper">
          {{ weatherStore.feelsLikeTemp ? "Feels like" : "&nbsp;" }}
        </div>
        <div class="feels-like-temp-wrapper">
          {{ weatherStore.feelsLikeTemp ? weatherStore.feelsLikeTemp + "°" : "&nbsp;" }}
        </div>
      </div>
    </div>

    <div class="search-wrapper">
      <SearchBar />
    </div>
  </div>
</template>

<script setup>
import SearchBar from "./SearchBar.vue";
import { useWeatherStore } from "../stores/weather-store";

const weatherStore = useWeatherStore();
</script>

<style scoped lang="scss">
.nav-container {
  z-index: 20;
  position: absolute;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  height: 100dvh;
  padding: 2% 4% 16% 4%;
  display: flex;
  flex-direction: row-reverse;
  justify-content: space-between;
  pointer-events: none;
}

.temp-container {
  align-self: flex-start;
  display: flex;
  align-items: flex-start;
  justify-content: flex-start;
  gap: 64px;
  // background: $background;
  border-radius: 16px;
  pointer-events: auto;
  padding: 16px;
}

.weather-card {
  background: rgba(242, 243, 248, 0.85);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);

  border-radius: 20px;
  padding: 20px 24px;

  border: 1px solid rgba(255, 255, 255, 0.6);

  box-shadow:
    0 10px 30px rgba(20, 25, 40, 0.08),
    0 2px 8px rgba(20, 25, 40, 0.05);
}

.weather-description-wrapper-wrapper {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.feels-like-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: space-between;
  height: 100%;
}

.feels-like-wrapper {
  font-size: 1.2rem;
  font-weight: 700;
}

.feels-like-temp-wrapper {
  font-size: 3.4rem;
  font-weight: 900;
  line-height: 3.2rem;
  color: $primary;
}

.weather-description-wrapper {
  font-size: 1rem;
  font-weight: 700;
}

body.screen--sm,
body.screen--xs {
  .nav-container {
    flex-direction: column;
  }

  .temp-container {
    width: 92vw;
    justify-content: space-between;
  }
}
</style>
