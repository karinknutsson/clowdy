<template>
  <div class="nav-container">
    <div class="temp-container">
      <div class="weather-description-wrapper-wrapper">
        <!-- <div class="feels-like-wrapper">{{ weatherStore.feelsLikeDescription }}</div> -->
        <div class="weather-description-wrapper">{{ weatherStore.weatherType }}</div>
        <div class="weather-description-wrapper">
          {{ "Air temp " + weatherStore.airTemp + "°" }}
        </div>
        <div class="weather-description-wrapper">{{ weatherStore.windDescription + " wind" }}</div>
      </div>
      <div class="feels-like-container">
        <div class="feels-like-wrapper">Feels like</div>
        <div class="feels-like-temp-wrapper">{{ weatherStore.feelsLikeTemp + "°" }}</div>
      </div>
    </div>

    <div class="search-wrapper">
      <SearchBar />
    </div>
  </div>
</template>

<script setup>
import { useQuasar } from "quasar";
import SearchBar from "./SearchBar.vue";
import gsap from "gsap";
import { useSearchStore } from "src/stores/search-store";
import { watch } from "vue";
import { useWeatherStore } from "../stores/weather-store";

const weatherStore = useWeatherStore();
const searchStore = useSearchStore();
const $q = useQuasar();

// function handleOpenSearch() {
//   gsap.to(".nav-btn", {
//     duration: 0.2,
//     opacity: 0,
//     ease: "power2.out",
//   });
// }

// function handleCloseSearch() {
//   gsap.to(".nav-btn", {
//     duration: 0.2,
//     opacity: 1,
//     ease: "power2.out",
//     delay: 0.3,
//   });
// }

// watch(
//   () => $q.screen.gt.sm,
//   (isDesktop) => {
//     if (isDesktop) {
//       handleCloseSearch();
//     } else if (searchStore.isSearchOpen) {
//       handleOpenSearch();
//     }
//   },
// );

// watch(
//   () => searchStore.isSearchOpen,
//   (isOpen) => {
//     if ($q.screen.gt.sm) return;

//     if (isOpen) {
//       handleOpenSearch();
//     } else {
//       handleCloseSearch();
//     }
//   },
// );
</script>

<style scoped lang="scss">
// button.nav-btn {
//   border: 0;
//   color: $deep-blue;
//   background: rgba(255, 255, 255, 0.7);
//   // box-shadow: 0 2px 24px 0 rgba(83, 15, 148, 0.3);
//   border-radius: 2px;
//   pointer-events: auto;
//   display: flex;
//   align-items: center;
//   justify-content: center;
// }

// button.desktop {
//   font-size: 16px;
//   font-weight: 700;
//   text-transform: uppercase;
//   padding: 0 32px;
//   width: 140px;
//   height: 56px;
// }

// button.mobile {
//   width: 44px;
//   height: 44px;

//   i {
//     font-size: 20px;
//   }
// }

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
  background: #ffde90;
  border-radius: 8px;
  pointer-events: auto;
  padding: 16px;
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
  font-weight: 900;
}

.feels-like-temp-wrapper {
  font-size: 3.4rem;
  font-weight: 900;
  line-height: 3.2rem;
  // border: 1px dotted red;
}

.weather-description-wrapper {
  font-size: 1rem;
  font-weight: 900;
}

.search-wrapper {
  // align-self: flex-start;
  // border: 1px dotted white;
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
