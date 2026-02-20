<template>
  <div class="search-bar glass-card" ref="searchBarRef">
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
          placeholder="Search locations"
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

  <div v-if="searchStore.suggestions.length" class="search-suggestions glass-card">
    <ul>
      <li v-for="suggestion in searchStore.suggestions">
        <button class="suggestion-list-button" @click="onSelectSuggestion(suggestion)">
          <div class="suggestion-header">
            <h3>{{ suggestion.name }}</h3>
          </div>
          <div v-if="suggestion.address">
            {{ suggestion.address }} ({{ (suggestion.distance / 1000).toFixed(2) }} km)
          </div>
          <div v-else>{{ suggestion.place_formatted }}</div>
        </button>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { computed, ref, watch, nextTick } from "vue";
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
const searchBarMarginBottom = ref("32px");

const emit = defineEmits(["showSearchSuggestions", "hideSearchSuggestions"]);

const searchBarFullWidth = computed(() => {
  if ($q.screen.lt.md) {
    return "100%";
  } else {
    return "420px";
  }
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

  searchBarMarginBottom.value = "0";

  if ($q.screen.gt.sm) {
    gsap.to(".search-suggestions", {
      width: searchBarFullWidth.value,
      duration: 0.3,
      ease: "power2.out",
      delay: 0.2,
    });
  }

  await nextTick();

  if (searchInputRef.value) {
    searchInputRef.value.focus();
  }
}

function onBlurSearch() {
  setTimeout(() => {
    isSearchFocused.value = false;
    searchBarMarginBottom.value = "32px";
  }, 300);

  if (!searchTerm.value) {
    searchStore.isSearchOpen = false;
    const width = $q.screen.lt.md ? "100%" : "196px";

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
      if ($q.screen.gt.md) {
        gsap.set(".search-suggestions", {
          width: searchBarFullWidth.value,
        });
      }
    }
  }
});

watch(searchBarFullWidth, () => {
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
    const width = $q.screen.lt.md ? "100%" : "196px";
    gsap.to(".search-bar", {
      duration: 0.3,
      width,
      ease: "power2.out",
    });
  }
});

watch(
  () => searchStore.suggestions.length,
  (length) => {
    if ($q.screen.gt.sm) return;

    if (length) {
      emit("showSearchSuggestions");
    } else {
      emit("hideSearchSuggestions");
    }
  },
);
</script>

<style scoped lang="scss">
ul {
  list-style-type: none;
  margin: 0;
  padding: 16px 0;
  width: 100%;
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
  font-size: 0.8rem;
  padding: 6px 8px;
  color: inherit;
  border-radius: 12px;
}

.search-bar {
  pointer-events: auto;
  width: 196px;
  height: 56px;
  padding: 0 8px;
  margin-bottom: v-bind(searchBarMarginBottom);
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
  width: v-bind(searchBarFullWidth);
}

.search-input {
  background: transparent;
  color: #0d0d0d;
  border: 0;
  padding: 6px 8px;
  font-size: 16px;
  font-weight: 600;
  width: 100%;
}

.search-icon {
  color: $charcoal;
  border: 0;
  padding: 8px;
  background: transparent;
  border-radius: 50%;
}

.search-close-button {
  background: transparent;
  border: 0;
  border-radius: 50%;
  color: $charcoal;
  padding: 8px;
  margin-left: 8px;
}

i {
  font-size: 22px;
}

.suggestion-header {
  h3 {
    font-weight: 700;
    font-size: 0.9rem;
    margin: 0;
    line-height: 120%;
    text-align: left;
  }
}

body.screen--sm,
body.screen--xs {
  .search-bar {
    width: 100%;
  }

  .search-suggestions {
    top: unset;
    bottom: calc(12vw + 36px);
    width: 92vw;
  }
}
</style>
