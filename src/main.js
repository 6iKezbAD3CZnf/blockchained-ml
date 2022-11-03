import Vue from "vue";
import App from "./App.vue";
import router from "./router";
import Argon from "./argon/plugins/argon-kit";
import './registerServiceWorker'
import "@/assets/scss/custom.scss";

Vue.config.productionTip = false;
Vue.use(Argon);
new Vue({
    router,
    render: h => h(App)
}).$mount("#app");
