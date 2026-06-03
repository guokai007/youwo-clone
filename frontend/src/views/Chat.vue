<template>
  <div>
    <div class="topbar">
      <div>
        <h1>和游我聊聊</h1>
        <p class="topbar-lead">不用完整，也不用漂亮，只要真实。</p>
      </div>
    </div>

    <div class="panel-layout">
      <!-- 对话区 -->
      <div class="surface chat-card">
        <!-- 连接状态 -->
        <div class="connection-card" :class="{ 'is-pending': chat.pending }">
          <div class="connection-dot"></div>
          <div>
            <strong>{{ chat.connected ? '已连接' : '离线模式' }}</strong>
            <p>游我在听，随时可以聊聊</p>
          </div>
        </div>

        <!-- 消息列表 -->
        <div class="message-list" ref="listRef">
          <div v-if="!chat.messages.length" class="empty-state">
            <h3>还没有对话</h3>
            <p>写下第一句话吧，游我会一直在这里。</p>
          </div>

          <div
            v-for="(msg, i) in chat.messages"
            :key="i"
            class="message"
            :class="{
              'user-message': msg.role === 'user',
              'assistant-message': msg.role === 'assistant',
              'is-pending': chat.pending && i === chat.messages.length - 1 && msg.role === 'user'
            }"
          >
            <p>{{ msg.content }}</p>
            <span v-if="msg.time" class="message-time">
              {{ formatTime(msg.time) }}
            </span>
          </div>
        </div>

        <!-- 快捷提示 -->
        <div v-if="!chat.messages.length" class="chat-suggestions">
          <button v-for="tip in tips" :key="tip" @click="inputText = tip">{{ tip }}</button>
        </div>

        <!-- 输入框 -->
        <div class="composer">
          <textarea
            v-model="inputText"
            placeholder="给游我发消息..."
            rows="3"
            @keydown.enter.exact.prevent="submit"
          ></textarea>
          <button @click="submit" :disabled="chat.pending || !inputText.trim()">
            {{ chat.pending ? '…' : '发送' }}
          </button>
        </div>
        <p class="composer-hint">Enter 发送，Shift + Enter 换行</p>
      </div>

      <!-- 侧边栏 -->
      <div class="future-panel">
        <div class="sidebar-card">
          <h3>未来会看到什么</h3>
          <p>今天的聊天会先成为记录。反复出现、被你认可的线索，才会慢慢沉淀成长期记忆。</p>
        </div>

        <div class="future-note" style="display: block;">
          <p style="grid-column: 1/-1;">
            每隔一段时间，游我会帮你回看这些日子里反复经过的事。
          </p>
        </div>

        <div class="sidebar-card" style="margin-top: 14px;">
          <button class="note-action ghost" style="font-size: 0.82rem; min-height: 30px;" @click="chat.clearHistory()">
            清空对话
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, nextTick, watch } from 'vue'
import { useChatStore } from '../stores/chat'

const chat = useChatStore()
const inputText = ref('')
const listRef = ref(null)

const tips = [
  '今天发生了什么事',
  '我最近在想……',
  '陪我想想',
]

function submit() {
  if (!inputText.value.trim() || chat.pending) return
  chat.send(inputText.value.trim())
  inputText.value = ''
}

function formatTime(time) {
  const d = new Date(time)
  return `${d.getHours().toString().padStart(2,'0')}:${d.getMinutes().toString().padStart(2,'0')}`
}

// 收到新消息后滚动到底部
watch(() => chat.messages.length, async () => {
  await nextTick()
  if (listRef.value) {
    listRef.value.scrollTop = listRef.value.scrollHeight
  }
})
</script>
