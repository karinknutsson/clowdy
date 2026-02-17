<template>
  <div class="search-bar" ref="searchBarRef">
    <form class="search-form">
      <div class="icon-input-container flex-center">
        <button type="button" @click="onOpenSearch" class="search-icon flex-center">
          <i class="pi pi-search icon"></i>
        </button>
        <input
          ref="searchInputRef"
          class="search-input"
          name="searchTerm"
          id="searchTerm"
          v-model="searchTerm"
          type="text"
          :placeholder="$q.screen.gt.xs ? 'Search' : ''"
          @focus="onOpenSearch"
          @blur="onBlurSearch"
        />
      </div>
      <button
        type="button"
        v-if="searchTerm"
        class="search-close-button flex-center"
        @click="clearSearchTerm"
      >
        <i class="pi pi-times icon"></i>
      </button>
    </form>
  </div>

  <div v-if="searchStore.suggestions.length" class="search-suggestions">
    <ul>
      <li v-for="suggestion in searchStore.suggestions">
        <button class="suggestion-list-button" @click="onSelectSuggestion(suggestion)">
          <div class="suggestion-header">
            <h3>{{ suggestion.name }}</h3>
          </div>
          <div v-if="suggestion.address">{{ suggestion.address }}</div>
          <div v-else>{{ suggestion.place_formatted }}</div>
          <div v-if="suggestion.distance">{{ (suggestion.distance / 1000).toFixed(2) }} km</div>
        </button>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { computed, ref, watch, nextTick, onMounted } from "vue";
import { useSearchStore } from "src/stores/search-store";
import { areCoordinates } from "src/utils/is-coordinate";
import { useQuasar } from "quasar";
import { onClickOutside } from "@vueuse/core";
import gsap from "gsap";

const $q = useQuasar();
const searchStore = useSearchStore();
const searchTerm = ref("");
const isSearchFocused = ref(false);
const searchBarRef = ref(null);
const searchInputRef = ref(null);

const searchBarBackground = computed(() => {
  return isSearchFocused.value ? "#ffffff" : "rgba(255, 255, 255, 0.7)";
});

const searchBarFullWidth = computed(() => {
  if ($q.screen.lt.md) {
    return "100%";
  } else {
    return "420px";
  }
});

onMounted(() => {
  // if ($q.screen.gt.sm) {
  gsap.set(".search-input", {
    padding: "6px 8px",
  });
  // }
});

function clearSearchTerm() {
  searchTerm.value = "";
  searchStore.suggestions = [];
  onBlurSearch();
}

function onSelectSuggestion(suggestion) {
  searchStore.selectSuggestion(suggestion);
  searchStore.suggestions = [];
}

async function onOpenSearch() {
  if (searchStore.isSearchOpen) return;

  searchStore.isSearchOpen = true;
  isSearchFocused.value = true;

  const delay = $q.screen.lt.md ? 0.2 : 0;

  gsap.to(".search-bar", {
    duration: 0.3,
    width: searchBarFullWidth.value,
    ease: "power2.out",
    delay,
  });

  gsap.to(".search-input", {
    padding: "6px 8px",
    duration: 0.1,
    delay: 0.2,
  });

  await nextTick();

  if (searchInputRef.value) {
    searchInputRef.value.focus();
  }
}

function onBlurSearch() {
  setTimeout(() => {
    isSearchFocused.value = false;
  }, 300);

  if (!searchTerm.value) {
    searchStore.isSearchOpen = false;
    const width = $q.screen.lt.md ? "100%" : "136px";

    gsap.to(".search-bar", {
      duration: 0.3,
      width,
      ease: "power2.out",
    });

    if ($q.screen.lt.md) {
      gsap.to(".search-input", {
        padding: "0",
        duration: 0.1,
        delay: 0.2,
      });
    }
  }
}

onClickOutside(searchBarRef, () => {
  onBlurSearch();
});

watch(searchTerm, async (value) => {
  if (!value) return;

  searchStore.isSearchOpen = true;

  if (areCoordinates(value)) {
    const coordinates = value.split(",");
    const lat = coordinates[0]?.trim();
    const lng = coordinates[1]?.trim();
    if (lat && lng) searchStore.selectedCoordinates = { lng: +lng, lat: +lat };
  } else {
    await searchStore.fetchSuggestions(value);

    if (searchStore.suggestions.length) {
      gsap.set(".search-suggestions", {
        width: searchBarFullWidth.value,
      });
    }
  }
});

watch(searchBarFullWidth, () => {
  // if ($q.screen.lt.md) {
  //   gsap.to(".search-input", {
  //     padding: "0",
  //     duration: 0.1,
  //   });
  // } else {
  gsap.to(".search-input", {
    padding: "6px 8px",
    duration: 0.1,
  });
  // }

  if (searchStore.isSearchOpen) {
    gsap.to(".search-bar", {
      duration: 0.3,
      width: searchBarFullWidth.value,
      ease: "power2.out",
      delay: 0.2,
    });

    if (searchStore.suggestions.length) {
      gsap.to(".search-suggestions", {
        width: searchBarFullWidth.value,
        duration: 0.3,
        ease: "power2.out",
        delay: 0.2,
      });
    }
  } else {
    const width = $q.screen.lt.md ? "100%" : "136px";
    gsap.to(".search-bar", {
      duration: 0.3,
      width,
      ease: "power2.out",
    });
  }
});
</script>

<style scoped lang="scss">
ul {
  list-style-type: none;
  margin: 0;
  padding: 8px 0;
  width: 100%;
  // width: v-bind(searchBarFullWidth);
}

li {
  padding: 0 8px;
}

.icon-input-container {
  width: 100%;
}

.suggestion-list-button {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  border: 0;
  background: transparent;
  font-size: 14px;
  padding: 8px;
  color: inherit;
}

.suggestion-list-button:hover {
  background: #ffffff;
}

.search-bar {
  pointer-events: auto;
  background: v-bind(searchBarBackground);
  // box-shadow: 0 2px 24px 0 rgba(83, 15, 148, 0.3);
  border-radius: 2px;
  width: 136px;
  height: 56px;
  padding: 0 8px;
}

.search-form {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.search-suggestions {
  pointer-events: auto;
  position: absolute;
  z-index: 5002;
  top: 96px;
  left: 4vw;
  background: rgba(255, 255, 255, 0.7);
  // box-shadow: 0 2px 24px 0 rgba(83, 15, 148, 0.3);
  border-radius: 2px;
}

.search-input {
  background: transparent;
  color: #0d0d0d;
  border: 0;
  padding: 0;
  font-size: 16px;
  font-weight: 600;
  width: 100%;
}

.search-icon {
  color: #0d0d0d;
  border: 0;
  padding: 8px;
  background: transparent;
  border-radius: 50%;
}

.search-close-button {
  background: transparent;
  border: 0;
  border-radius: 50%;
  color: #0d0d0d;
  padding: 8px;
  margin-left: 8px;
}

i {
  font-size: 22px;
}

.suggestion-header {
  h3 {
    font-weight: 700;
    font-size: 14px;
    margin: 0;
    line-height: 120%;
  }
}

body.screen--sm,
body.screen--xs {
  // .search-bar {
  //   width: 44px;
  //   height: 44px;
  //   padding: 0 5px;
  // }

  // i {
  //   font-size: 18px;
  // }
}
</style>
