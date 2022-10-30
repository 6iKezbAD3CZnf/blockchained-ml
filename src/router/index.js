import { createWebHistory, createRouter } from "vue-router";
import HelloWorld from "@/components/HelloWorld.vue";
import TheWelcome from "@/components/TheWelcome.vue";

const routes = [
  {
    path: "/",
    name: "Home",
    component: TheWelcome,
  },
  {
    path: "/about",
    name: "About",
    component: HelloWorld,
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
