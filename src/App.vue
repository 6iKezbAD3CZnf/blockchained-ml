<script setup>
import HelloWorld from './components/HelloWorld.vue'
import TheWelcome from './components/TheWelcome.vue'
import EthereumInteraction from './components/EthereumInteraction.vue'
</script>

<template>
  <header>
    <router-link to="/train">Train</router-link>&nbsp
    <router-link to="/infer">Infer</router-link>&nbsp
    <router-link to="/model">Model</router-link>&nbsp
    Blockchained Learning&nbsp
    <a href="https://github.com/6iKezbAD3CZnf/blockchained-learning" target="_blank" rel="noopener">Github</a>&nbsp
    <EthereumInteraction />
  </header>

  <main>
    <router-view />
  </main>
</template>
