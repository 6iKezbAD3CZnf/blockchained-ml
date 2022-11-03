<template>
    <div id="app">
        <Header/>
        <main>
            <fade-transition origin="center" mode="out-in" :duration="250">
                <router-view/>
            </fade-transition>
        </main>
        <router-view name="footer"></router-view>
    </div>
</template>
<script>
import { FadeTransition } from "vue2-transitions";
import Header from "./components/Header";

export default {
    components: {
        FadeTransition,
        Header
    }
};
</script>
