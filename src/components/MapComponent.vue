<template>
  <div class="overlay" v-if="showOverlay" :style="overlayStyle"></div>

  <div id="map" class="map-container"></div>
</template>

<script setup>
import { computed, onMounted, ref, watch } from "vue";
import mapboxgl from "mapbox-gl";
import { useQuasar } from "quasar";
import { useSearchStore } from "src/stores/search-store";
import { useMapStore } from "src/stores/map-store";
import { useWeatherStore } from "src/stores/weather-store";
import fogVertexShader from "src/shaders/fog/vertexShader.glsl?raw";
import fogFragmentShader from "src/shaders/fog/fragmentShader.glsl?raw";
import { createProgram, createFullscreenQuad } from "src/utils/shader-helpers";

const $q = useQuasar();
const searchStore = useSearchStore();
const mapStore = useMapStore();
const weatherStore = useWeatherStore();

let map;
const apiKey = import.meta.env.VITE_MAPBOX_API_KEY;
let currentLayerId = null;
const x = ref(0);
const y = ref(0);
const showOverlay = ref(false);

const overlayStyle = computed(() => {
  const radius = Math.max(window.innerWidth, window.innerHeight) * 0.5;
  return {
    maskImage: `radial-gradient(circle ${radius}px at ${x.value}px ${y.value}px, transparent 0%, transparent 30%, black 100%)`,
    WebkitMaskImage: `radial-gradient(circle ${radius}px at ${x.value}px ${y.value}px, transparent 0%, transparent 30%, black 100%)`,
  };
});

const mapStyles = {
  placeholder: "mapbox://styles/karinmiriam/cml9i2zeb001801s88vlc747z",
  winter: "mapbox://styles/karinmiriam/cml9alr3f002501qzdrwabuer",
  autumn: "mapbox://styles/karinmiriam/cml9fuw9f006c01sj5hqd6ytl",
  spring: "mapbox://styles/karinmiriam/cml9h8dgz003f01r07i9h60bk",
  summer: "mapbox://styles/karinmiriam/cml9hill2001801r02ghifgjr",
  tropical: "mapbox://styles/karinmiriam/cml9hqmkw000t01s7frzh09k3",
  desert: "mapbox://styles/karinmiriam/cml9hvfca003j01r0d3jjcbkg",
};

function removeLayerIfExists(layerId) {
  if (map.getLayer(layerId)) map.removeLayer(layerId);
}

function addShaderLayer(layerId, vertexShader, fragmentShader) {
  if (currentLayerId === layerId && map.getLayer(layerId)) return;

  if (currentLayerId && currentLayerId !== layerId) removeLayerIfExists(currentLayerId);

  map.addLayer({
    id: layerId,
    type: "custom",
    renderingMode: "2d",

    onAdd: function (_, gl) {
      this.program = createProgram(gl, vertexShader, fragmentShader);

      if (!this.program) return;

      this.aPos = gl.getAttribLocation(this.program, "a_pos");
      this.uIntensity = gl.getUniformLocation(this.program, "uIntensity");
      this.uResolution = gl.getUniformLocation(this.program, "uResolution");
      this.buffer = createFullscreenQuad(gl);
    },

    render: function (gl, _) {
      if (!this.program) return;

      gl.useProgram(this.program);

      gl.bindBuffer(gl.ARRAY_BUFFER, this.buffer);
      gl.enableVertexAttribArray(this.aPos);
      gl.vertexAttribPointer(this.aPos, 2, gl.FLOAT, false, 0, 0);

      gl.uniform1f(this.uIntensity, 0.6);
      gl.uniform2f(this.uResolution, gl.canvas.width, gl.canvas.height);

      gl.enable(gl.BLEND);
      gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

      gl.drawArrays(gl.TRIANGLES, 0, 6);

      gl.disableVertexAttribArray(this.aPos);
      gl.bindBuffer(gl.ARRAY_BUFFER, null);

      map.triggerRepaint();
    },

    onRemove: function (_, gl) {
      if (this.buffer) gl.deleteBuffer(this.buffer);

      if (this.program && gl.getProgramParameter(this.program, gl.DELETE_STATUS))
        gl.deleteProgram(this.program);
    },
  });

  currentLayerId = layerId;
}

async function setMapStyle() {
  const data = await weatherStore.fetchWeatherData(mapStore.lng, mapStore.lat);

  console.log(data.weather[0].main);

  if (
    data.weather[0].main === "Mist" ||
    data.weather[0].main === "Fog" ||
    data.weather[0].main === "Haze"
  ) {
    addShaderLayer("fogLayer", fogVertexShader, fogFragmentShader);
  }

  if (data.main.temp <= 0) {
    map.setStyle(mapStyles.winter);
  } else if (data.main.temp > 0 && data.main.temp <= 10) {
    map.setStyle(mapStyles.autumn);
  } else if (data.main.temp > 15 && data.main.temp <= 20) {
    map.setStyle(mapStyles.spring);
  } else if (data.main.temp > 20 && data.main.temp <= 30) {
    map.setStyle(mapStyles.summer);
  } else if (data.main.temp > 30 && data.main.temp <= 40) {
    map.setStyle(mapStyles.tropical);
  } else if (data.main.temp > 40) {
    map.setStyle(mapStyles.desert);
  }
}

onMounted(async () => {
  map = new mapboxgl.Map({
    container: "map",
    style: mapStyles.placeholder,
    style: null,
    zoom: mapStore.zoom,
    center: [mapStore.lng, mapStore.lat],
    accessToken: apiKey ?? "",
  });

  map.on("load", async () => {
    await setMapStyle();
  });

  map.on("moveend", async () => {
    mapStore.setCoordinates(map.getCenter().lng, map.getCenter().lat);
    mapStore.setZoom(map.getZoom());

    await setMapStyle();
  });
});

watch(
  () => [searchStore.selectedCoordinates.lng, searchStore.selectedCoordinates.lat],
  ([lng, lat]) => {
    if (lng && lat) {
      mapStore.setCoordinates(lng, lat);
      mapStore.setZoom(14);

      map.flyTo({
        center: [lng, lat],
        zoom: 14,
        essential: true,
      });
    }
  },
);
</script>

<style scoped lang="scss">
.overlay {
  position: absolute;
  inset: 0;
  background: rgba(255, 255, 255, 0.67);
  pointer-events: none;
  z-index: 2000;
}

:deep(a) {
  color: $font-color;
  text-decoration: none;
  font-size: 8px;
}

:deep(.mapboxgl-marker) {
  pointer-events: none;
}

.map-container {
  width: 100%;
  height: 100vh;
  height: 100dvh;
}
</style>
