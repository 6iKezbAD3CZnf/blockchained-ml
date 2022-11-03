import Vue from "vue";
import Router from "vue-router";
import Home from "./components/Home";
import Train from "./components/Train";
import Infer from "./components/Infer";
import Model from "./components/Model";

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
        {
            path: "/infer",
            name: "infer",
            components: {
                default: Infer
            }
        },
        {
            path: "/model",
            name: "model",
            components: {
                default: Model
            }
        }
    ],
    scrollBehavior: to => {
        if (to.hash) {
            return { selector: to.hash };
        } else {
            return { x: 0, y: 0 };
        }
    }
});
