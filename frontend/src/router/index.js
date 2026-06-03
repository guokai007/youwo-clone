import { createRouter, createWebHashHistory } from 'vue-router'
import Today from '../views/Today.vue'
import Chat from '../views/Chat.vue'
import Records from '../views/Records.vue'
import Review from '../views/Review.vue'
import Preferences from '../views/Preferences.vue'

const routes = [
  { path: '/', component: Today },
  { path: '/chat', component: Chat },
  { path: '/records', component: Records },
  { path: '/review', component: Review },
  { path: '/preferences', component: Preferences },
]

export default createRouter({
  history: createWebHashHistory(),
  routes,
})
