<template>
  <div class="overlay" v-if="showOverlay" :style="overlayStyle"></div>

  <div ref="mapContainer" id="map" class="map-container"></div>
</template>

<script setup>
import { computed, onMounted, ref, watch } from "vue";
import mapboxgl from "mapbox-gl";
import { useQuasar } from "quasar";
import { useSearchStore } from "src/stores/search-store";
import { useMapStore } from "src/stores/map-store";
import { useWeatherStore } from "src/stores/weather-store";
import vertexShader from "src/shaders/fog/vertexShader.glsl?raw";
import fragmentShader from "src/shaders/fog/fragmentShader.glsl?raw";

const $q = useQuasar();
const searchStore = useSearchStore();
const mapStore = useMapStore();
const weatherStore = useWeatherStore();

let map;
const apiKey = import.meta.env.VITE_MAPBOX_API_KEY;
const mapContainer = ref(null);
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

async function setMapStyle() {
  const data = await weatherStore.fetchWeatherData(mapStore.lng, mapStore.lat);

  console.log(data);

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

function compileShader(gl, type, source) {
  const shader = gl.createShader(type);
  gl.shaderSource(shader, source);
  gl.compileShader(shader);

  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
    console.error(gl.getShaderInfoLog(shader));
    gl.deleteShader(shader);
    return null;
  }

  return shader;
}

function createProgram(gl, vertexSource, fragmentSource) {
  const vs = compileShader(gl, gl.VERTEX_SHADER, vertexSource);
  const fs = compileShader(gl, gl.FRAGMENT_SHADER, fragmentSource);

  if (!vs || !fs) {
    console.error("Shader compilation failed");
    return null;
  }

  const program = gl.createProgram();
  gl.attachShader(program, vs);
  gl.attachShader(program, fs);
  gl.linkProgram(program);

  if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
    console.error("Program linking error:", gl.getProgramInfoLog(program));
    gl.deleteProgram(program);
    return null;
  }

  return program;
}

function createFullscreenQuad(gl) {
  const buffer = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, buffer);

  gl.bufferData(
    gl.ARRAY_BUFFER,
    new Float32Array([-1, -1, 1, -1, -1, 1, -1, 1, 1, -1, 1, 1]),
    gl.STATIC_DRAW,
  );

  return buffer;
}

onMounted(() => {
  map = new mapboxgl.Map({
    container: "map",
    style: mapStyles.placeholder,
    zoom: mapStore.zoom,
    center: [mapStore.lng, mapStore.lat],
    accessToken: apiKey ?? "",
  });

  setMapStyle();

  map.on("load", () => {
    map.addLayer({
      id: "weather-overlay",
      type: "custom",
      renderingMode: "2d",

      onAdd: function (map, gl) {
        this.program = createProgram(gl, vertexShader, fragmentShader);

        if (!this.program) {
          console.error("WebGL program is null — aborting layer setup");
          return;
        }

        this.aPos = gl.getAttribLocation(this.program, "a_pos");
        this.uIntensity = gl.getUniformLocation(this.program, "uIntensity");
        this.uResolution = gl.getUniformLocation(this.program, "uResolution");
        this.buffer = createFullscreenQuad(gl);
      },

      render: function (gl, matrix) {
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

      onRemove: function () {
        if (this.buffer) {
          gl.deleteBuffer(this.buffer);
        }
      },
    });
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
