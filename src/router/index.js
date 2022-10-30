import { createWebHistory, createRouter } from "vue-router";
import Train from "@/components/Train.vue";
import Infer from "@/components/Infer.vue";
import Model from "@/components/Model.vue";

const routes = [
  {
    path: "/train",
    name: "Train",
    component: Train,
  },
  {
    path: "/infer",
    name: "Infer",
    component: Infer,
  },
  {
    path: "/model",
    name: "Model",
    component: Model,
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
