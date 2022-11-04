<template>
    <div id="app">
        <Header/>
        <main>
            <section class="section-home section-shaped my-0">
                <div class="shape shape-style-1 shape-custom">
                </div>
                <div class="container shape-container d-flex">
                    <fade-transition origin="center" mode="out-in" :duration="250">
                        <router-view/>
                    </fade-transition>
                </div>
            </section>
        </main>
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
