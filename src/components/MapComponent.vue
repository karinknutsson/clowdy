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

import vertexShader from "src/shaders/vertexShader.glsl?raw";

import fogFragmentShader from "src/shaders/atmosphere/fogFragmentShader.glsl?raw";
import mistFragmentShader from "src/shaders/atmosphere/mistFragmentShader.glsl?raw";
import hazeFragmentShader from "src/shaders/atmosphere/hazeFragmentShader.glsl?raw";
import dustFragmentShader from "src/shaders/atmosphere/dustFragmentShader.glsl?raw";
import ashFragmentShader from "src/shaders/atmosphere/ashFragmentShader.glsl?raw";
import smokeFragmentShader from "src/shaders/atmosphere/smokeFragmentShader.glsl?raw";

import overcastCloudsFragmentShader from "src/shaders/clouds/overcastCloudsFragmentShader.glsl?raw";
import brokenCloudsFragmentShader from "src/shaders/clouds/brokenCloudsFragmentShader.glsl?raw";
import scatteredCloudsFragmentShader from "src/shaders/clouds/scatteredCloudsFragmentShader.glsl?raw";
import fewCloudsFragmentShader from "src/shaders/clouds/fewCloudsFragmentShader.glsl?raw";

import rainFragmentShader from "src/shaders/rain/rainFragmentShader.glsl?raw";

import { createProgram, createFullscreenQuad } from "src/utils/shader-helpers";

const $q = useQuasar();
const searchStore = useSearchStore();
const mapStore = useMapStore();
const weatherStore = useWeatherStore();

let map;
const apiKey = import.meta.env.VITE_MAPBOX_API_KEY;
let currentLayerId = null;
let displayedStyle = null;
let texturePaths = [];
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
  if (layerId && map.getLayer(layerId)) map.removeLayer(layerId);
}

function addShaderLayer(layerId, vertexShader, fragmentShader) {
  removeLayerIfExists(currentLayerId);

  let startTime = performance.now();

  map.addLayer({
    id: layerId,
    type: "custom",
    renderingMode: "2d",

    onAdd: function (_, gl) {
      this.textures = [];
      this.textureUniforms = [];
      this.nextTextureUnit = 0;

      this.program = createProgram(gl, vertexShader, fragmentShader);
      if (!this.program) return;

      // Set attributes and uniforms
      this.aPos = gl.getAttribLocation(this.program, "a_pos");
      this.uIntensity = gl.getUniformLocation(this.program, "uIntensity");
      this.uResolution = gl.getUniformLocation(this.program, "uResolution");

      // if (texturePath) {
      //   this.uTexture = gl.getUniformLocation(this.program, "uTexture");
      //   this.uTime = gl.getUniformLocation(this.program, "uTime");
      // }

      if (texturePaths.length) {
        for (let i = 0; i < texturePaths.length; i++) {
          this.textureUniforms.push(gl.getUniformLocation(this.program, `uTexture${i}`));
        }
        this.uTime = gl.getUniformLocation(this.program, "uTime");
      }

      this.buffer = createFullscreenQuad(gl);

      // Load textures if needed
      if (texturePaths.length) {
        texturePaths.forEach((path, index) => {
          this.addTexture(gl, path);
        });
      }

      // if (texturePath) {
      //   this.texture = gl.createTexture();
      //   gl.bindTexture(gl.TEXTURE_2D, this.texture);
      //   gl.texImage2D(
      //     gl.TEXTURE_2D,
      //     0,
      //     gl.RGBA,
      //     1,
      //     1,
      //     0,
      //     gl.RGBA,
      //     gl.UNSIGNED_BYTE,
      //     new Uint8Array([0, 0, 255, 255]),
      //   );

      //   const image = new Image();
      //   image.src = texturePath;
      //   image.onload = () => {
      //     gl.bindTexture(gl.TEXTURE_2D, this.texture);
      //     gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);
      //     gl.generateMipmap(gl.TEXTURE_2D);
      //     gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
      //     gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
      //     gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
      //   };
      // }
    },

    addTexture(gl, path) {
      const texture = gl.createTexture();
      gl.bindTexture(gl.TEXTURE_2D, texture);

      // 1x1 placeholder
      gl.texImage2D(
        gl.TEXTURE_2D,
        0,
        gl.RGBA,
        1,
        1,
        0,
        gl.RGBA,
        gl.UNSIGNED_BYTE,
        new Uint8Array([0, 0, 0, 255]),
      );

      const image = new Image();
      image.src = path;
      image.onload = () => {
        gl.bindTexture(gl.TEXTURE_2D, texture);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);
        gl.generateMipmap(gl.TEXTURE_2D);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
      };

      this.textures.push({ texture, unit: this.nextTextureUnit });
      this.nextTextureUnit++;
    },

    render: function (gl, _) {
      if (!this.program) return;

      gl.useProgram(this.program);

      const time = (performance.now() - startTime) * 0.001;
      gl.uniform1f(this.uTime, time);

      this.textures.forEach((t, i) => {
        gl.activeTexture(gl.TEXTURE0 + t.unit);
        gl.bindTexture(gl.TEXTURE_2D, t.texture);
        gl.uniform1i(this.textureUniforms[i], t.unit);
      });

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

  console.log(data.weather[0]);

  let currentStyle;

  if (data.main.temp <= 0) {
    currentStyle = "winter";
  } else if (data.main.temp > 0 && data.main.temp <= 10) {
    currentStyle = "autumn";
  } else if (data.main.temp > 10 && data.main.temp <= 20) {
    currentStyle = "spring";
  } else if (data.main.temp > 20 && data.main.temp <= 30) {
    currentStyle = "summer";
  } else if (data.main.temp > 30 && data.main.temp <= 40) {
    currentStyle = "tropical";
  } else if (data.main.temp > 40) {
    currentStyle = "desert";
  }

  const testWeather = "Clouds";

  function setShader() {
    // switch (data.weather[0].main) {
    switch (testWeather) {
      // Atmospheric conditions
      case "Fog":
        texturePaths = [];
        addShaderLayer("fogLayer", vertexShader, fogFragmentShader);
        break;
      case "Mist":
        texturePaths = [];
        addShaderLayer("mistLayer", vertexShader, mistFragmentShader);
        break;
      case "Dust":
      case "Sand":
        texturePaths = [];
        addShaderLayer("dustLayer", vertexShader, dustFragmentShader);
        break;
      case "Haze":
        texturePaths = [];
        addShaderLayer("hazeLayer", vertexShader, hazeFragmentShader);
        break;
      case "Ash":
        texturePaths = ["./noise-textures/Perlin23-512x512.png"];
        addShaderLayer("ashLayer", vertexShader, ashFragmentShader);
        break;
      case "Smoke":
        texturePaths = ["./noise-textures/SuperPerlin2-512x512.png"];
        addShaderLayer("smokeLayer", vertexShader, smokeFragmentShader);
        break;

      // Clouds
      case "Clouds":
        if (data.weather[0].description.includes("overcast")) {
          texturePaths = ["./noise-textures/Milky6-512x512.png"];
          addShaderLayer("overcastCloudsLayer", vertexShader, overcastCloudsFragmentShader);
        } else if (data.weather[0].description.includes("broken")) {
          texturePaths = ["./noise-textures/Milky7-512x512.png"];
          addShaderLayer("brokenCloudsLayer", vertexShader, brokenCloudsFragmentShader);
        } else if (data.weather[0].description.includes("scattered")) {
          texturePaths = ["./noise-textures/Milky6-512x512.png"];
          addShaderLayer("scatteredCloudsLayer", vertexShader, scatteredCloudsFragmentShader);
        } else {
          texturePaths = ["./noise-textures/Milky6-512x512.png"];
          addShaderLayer("fewCloudsLayer", vertexShader, fewCloudsFragmentShader);
        }
        break;

      // Precipitation
      case "Rain":
        texturePaths = [
          "./noise-textures/Milky6-512x512.png",
          "./noise-textures/Perlin18-512x512.png",
        ];
        addShaderLayer("rainLayer", vertexShader, rainFragmentShader);
        break;
      default:
        removeLayerIfExists(currentLayerId);
        break;
    }
  }

  if (currentStyle !== displayedStyle) {
    map.setStyle(mapStyles[currentStyle]);
    displayedStyle = currentStyle;

    map.on("style.load", () => {
      setShader();
    });
  } else {
    setShader();
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

  await setMapStyle();

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

      setMapStyle();
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
