<script setup>
import HelloWorld from './components/HelloWorld.vue'
import TheWelcome from './components/TheWelcome.vue'
import EthereumInteraction from './components/EthereumInteraction.vue'
import ModelTrain from './components/ModelTrain.vue'
</script>

<template>
  <header>
    <img alt="Vue logo" class="logo" src="./assets/logo.svg" width="125" height="125" />

    <div class="wrapper">
      <HelloWorld msg="Blockchained Learning" />
    </div>
  </header>

  <main>
    <EthereumInteraction />
  </main>
  
  <div>
    <ModelTrain />
  </div>
</template>

<script>
export default {
  methods: {
    toTrain(){
      this.$router.push('./components/ModelTrain.vue')
    }
  }
}
</script>

<style scoped>
header {
  line-height: 1.5;
}

.logo {
  display: block;
  margin: 0 auto 2rem;
}

@media (min-width: 1024px) {
  header {
    display: flex;
    place-items: center;
    padding-right: calc(var(--section-gap) / 2);
  }

  .logo {
    margin: 0 2rem 0 0;
  }

  header .wrapper {
    display: flex;
    place-items: flex-start;
    flex-wrap: wrap;
  }
}
</style>
