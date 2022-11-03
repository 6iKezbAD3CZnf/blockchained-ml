import Vue from "vue";
import Router from "vue-router";
import Home from "./components/Home";
import Train from "./components/Train";

Vue.use(Router);

export default new Router({
    linkExactActiveClass: "active",
    routes: [
        {
            path: "/",
            name: "home",
            components: {
                default: Home
            }
        },
        {
            path: "/train",
            name: "train",
            components: {
                default: Train
            }
        },
    ],
    scrollBehavior: to => {
        if (to.hash) {
            return { selector: to.hash };
        } else {
            return { x: 0, y: 0 };
        }
    }
});
