<template>
  <div class="navbar-container">
    <div class="search-wrapper">
      <SearchBar />
    </div>

    <div
      class="logo-wrapper"
      :class="$q.screen.gt.sm ? 'logo-wrapper-desktop' : 'logo-wrapper-mobile'"
    >
      <div :class="$q.screen.gt.sm ? 'logo' : 'logo-mobile'">Nimbus</div>
    </div>

    <div v-if="!showAboutPopup" class="about-button-wrapper">
      <button
        type="button"
        class="nav-btn"
        :class="$q.screen.gt.sm ? 'desktop' : 'mobile'"
        @click="handleOpenAboutPopup"
      >
        <template v-if="$q.screen.gt.sm">About</template
        ><i v-else class="pi pi-info-circle icon"></i>
      </button>
    </div>
  </div>
  <div ref="aboutPopupRef" class="about-popup">
    <template v-if="showAboutPopupText">
      <div class="close-wrapper">
        <button type="button" class="close-button flex-center" @click="handleCloseAboutPopup">
          <i class="pi pi-times icon"></i>
        </button>
      </div>
      <div
        v-if="$q.screen.lt.md"
        class="logo-wrapper"
        :class="$q.screen.gt.xs ? 'logo-wrapper-desktop' : 'logo-wrapper-mobile'"
      >
        <div :class="$q.screen.gt.sm ? 'logo-wrapper-desktop' : 'logo-wrapper-mobile'">
          <div :class="$q.screen.gt.sm ? 'logo' : 'logo-mobile'">Nimbus</div>
        </div>
      </div>
      <div class="about-text-wrapper">
        <p>{{ aboutText[0] }}</p>
        <p>{{ aboutText[1] }}</p>
      </div>
    </template>
  </div>
</template>

<script setup>
import { useQuasar } from "quasar";
import SearchBar from "./SearchBar.vue";
import gsap from "gsap";
import { useSearchStore } from "src/stores/search-store";
import { computed, ref, watch, onMounted, nextTick } from "vue";
import { aboutText } from "./about-text";
import { onClickOutside } from "@vueuse/core";

const searchStore = useSearchStore();
const $q = useQuasar();
const emit = defineEmits(["openPopup", "closePopup"]);
const showAboutPopup = ref(true);
const showAboutPopupText = ref(false);
const aboutPopupRef = ref(null);
const aboutPopupFullHeight = ref(0);

const aboutPopupFullWidth = computed(() => {
  if ($q.screen.lt.md) {
    return "92vw";
  } else if ($q.screen.md) {
    return "340px";
  } else {
    return "420px";
  }
});

onMounted(async () => {
  await nextTick();
  if (aboutPopupRef.value) aboutPopupFullHeight.value = aboutPopupRef.value.offsetHeight;
});

onClickOutside(aboutPopupRef, () => {
  if (showAboutPopup.value) handleCloseAboutPopup();
});

function hideLogo() {
  gsap.to(".logo-wrapper", {
    duration: 0.2,
    opacity: 0,
    ease: "power2.out",
  });
}

function showLogo(delay) {
  gsap.to(".logo-wrapper", {
    duration: 0.2,
    opacity: 1,
    ease: "power2.out",
    delay,
  });
}

function handleOpenSearch() {
  hideLogo();

  gsap.to(".nav-btn", {
    duration: 0.2,
    opacity: 0,
    ease: "power2.out",
  });
}

function handleCloseSearch() {
  showLogo(0.3);

  gsap.to(".nav-btn", {
    duration: 0.2,
    opacity: 1,
    ease: "power2.out",
    delay: 0.3,
  });
}

function handleOpenAboutPopup() {
  setTimeout(() => {
    showAboutPopup.value = true;
  }, 300);

  setTimeout(() => {
    showAboutPopupText.value = true;
  }, 800);

  emit("openPopup");

  if ($q.screen.lt.md) {
    hideLogo();

    gsap.to(".search-wrapper", {
      duration: 0.2,
      opacity: 0,
      ease: "power2.out",
    });
  }

  gsap.to(".about-popup", {
    duration: 0.1,
    opacity: 1,
    ease: "power2.out",
    delay: 0.2,
  });

  gsap.to(".about-popup", {
    duration: 0.3,
    width: aboutPopupFullWidth.value,
    ease: "power2.out",
    delay: 0.3,
  });

  gsap.to(".about-popup", {
    duration: 0.4,
    height: aboutPopupFullHeight.value + "px",
    ease: "power2.out",
    delay: 0.45,
  });

  gsap.set(".about-popup", {
    height: "auto",
    delay: 0.85,
  });
}

function handleCloseAboutPopup() {
  showAboutPopupText.value = false;

  setTimeout(() => {
    showAboutPopup.value = false;
  }, 400);

  if (aboutPopupRef.value) {
    gsap.set(aboutPopupRef.value, {
      height: aboutPopupFullHeight.value + "px",
    });
  }

  emit("closePopup");

  if ($q.screen.lt.md) {
    showLogo(0.5);

    gsap.to(".search-wrapper", {
      duration: 0.2,
      opacity: 1,
      ease: "power2.out",
      delay: 0.4,
    });
  }

  const width = $q.screen.gt.sm ? "140px" : "44px";
  const height = $q.screen.gt.sm ? "56px" : "44px";

  gsap.to(".about-popup", {
    duration: 0.1,
    opacity: 0,
    ease: "power2.out",
    delay: 0.45,
  });

  gsap.to(".about-popup", {
    duration: 0.2,
    width,
    ease: "power2.out",
    delay: 0.3,
  });

  gsap.to(".about-popup", {
    duration: 0.3,
    height: height,
    ease: "power2.out",
  });
}

function setInfoWidth(isDesktop) {
  gsap.to(".about-popup", {
    duration: 0.2,
    width: aboutPopupFullWidth.value,
    ease: "power2.out",
  });

  if (isDesktop) {
    showLogo(0.5);

    gsap.to(".search-wrapper", {
      duration: 0.2,
      opacity: 1,
      ease: "power2.out",
      delay: 0.4,
    });
  } else {
    hideLogo();

    gsap.to(".search-wrapper", {
      duration: 0.2,
      opacity: 0,
      ease: "power2.out",
    });
  }
}

watch(
  () => $q.screen.gt.sm,
  (isDesktop) => {
    if (isDesktop) {
      handleCloseSearch();
    } else if (searchStore.isSearchOpen) {
      handleOpenSearch();
    }

    if (showAboutPopup.value) setInfoWidth(isDesktop);
  },
);

watch(
  () => searchStore.isSearchOpen,
  (isOpen) => {
    if ($q.screen.gt.sm) return;

    if (isOpen) {
      handleOpenSearch();
    } else {
      handleCloseSearch();
    }
  },
);

watch(aboutPopupFullHeight, (value) => {
  if (value) {
    const width = $q.screen.gt.sm ? "140px" : "44px";
    const height = $q.screen.gt.sm ? "56px" : "44px";

    gsap.set(".about-popup", {
      width,
      height,
    });

    showAboutPopup.value = false;
  }
});
</script>

<style scoped lang="scss">
button.nav-btn {
  border: 0;
  color: $deep-blue;
  background: rgba(255, 255, 255, 0.7);
  box-shadow: 0 2px 24px 0 rgba(83, 15, 148, 0.3);
  border-radius: 2px;
  pointer-events: auto;
  display: flex;
  align-items: center;
  justify-content: center;
}

button.desktop {
  font-size: 16px;
  font-weight: 700;
  text-transform: uppercase;
  padding: 0 32px;
  width: 140px;
  height: 56px;
}

button.mobile {
  width: 44px;
  height: 44px;

  i {
    font-size: 20px;
  }
}

.close-wrapper {
  width: 100%;
  display: flex;
  justify-content: flex-end;
  margin: 6px 0 12px 0;
  // background: magenta;
}

.navbar-container {
  z-index: 20;
  position: absolute;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100px;
  padding: 0 4vw;
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  align-items: center;
  pointer-events: none;
}

.logo-wrapper-desktop {
  transform: translateY(7px);
  display: flex;
  justify-content: center;
}

.logo-wrapper-mobile {
  transform: translateY(4px);
  display: flex;
  justify-content: center;
}

.search-wrapper {
  justify-self: start;
}

.about-popup {
  position: absolute;
  top: 22px;
  right: 4vw;
  width: v-bind(aboutPopupFullWidth);
  background: white;
  box-shadow: 0 2px 24px 0 rgba(83, 15, 148, 0.3);
  opacity: 0;
  border-radius: 2px;
  z-index: 19;
  padding: 4px 24px 16px 30px;
  min-height: 56px;
}

.about-button-wrapper {
  justify-self: end;
}

.close-button {
  pointer-events: auto;
}

body.screen--sm,
body.screen--xs {
  .about-popup {
    width: v-bind(aboutPopupFullWidth);
    top: 28px;
    min-height: 44px;
  }

  .about-text-wrapper {
    margin-top: 32px;
  }
}
</style>
