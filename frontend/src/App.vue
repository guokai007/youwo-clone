<template>
  <div class="app-shell">
    <!-- Sidebar -->
    <aside class="sidebar">
      <button class="brand">
        <div class="brand-mark">游</div>
        <div>
          <span class="brand-name">游我</span>
          <span class="brand-caption">记忆安放的地方</span>
        </div>
      </button>

      <nav class="module-nav">
        <router-link to="/" class="module-link">
          <span class="module-dot"></span>
          今天
        </router-link>
        <router-link to="/chat" class="module-link">
          <span class="module-dot"></span>
          聊聊
        </router-link>
        <router-link to="/records" class="module-link">
          <span class="module-dot"></span>
          留存
        </router-link>
        <router-link to="/review" class="module-link">
          <span class="module-dot"></span>
          回望
        </router-link>
        <router-link to="/preferences" class="module-link">
          <span class="module-dot"></span>
          偏好
        </router-link>
      </nav>
    </aside>

    <!-- Main -->
    <main class="main-content">
      <router-view />
    </main>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useChatStore } from './stores/chat'

const chatStore = useChatStore()
onMounted(() => {
  chatStore.loadHistory()
})
</script>
