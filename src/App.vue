<script setup>
import SwitchChain from './components/SwitchChain.vue'
import ConnectMetaMask from './components/ConnectMetaMask.vue'
</script>

<template>
  <header>
    <router-link to="/train">Train </router-link>
    <router-link to="/infer">Infer </router-link>
    <router-link to="/model">Model </router-link>
    Blockchained Learning
    <a href="https://github.com/6iKezbAD3CZnf/blockchained-learning" target="_blank" rel="noopener">Github</a>
    <SwitchChain />
    <ConnectMetaMask />
  </header>

  <main>
    <router-view />
  </main>
</template>
