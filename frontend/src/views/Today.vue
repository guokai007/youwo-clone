<template>
  <div>
    <div class="topbar">
      <div>
        <h1>今天先放在这里</h1>
        <p class="topbar-lead">不用整理好，游我会陪你慢慢留住它。哪怕只是一个开头，也可以成为未来回看的线索。</p>
        <p class="soft-status">
          <span></span>
          本地记忆已开启 · 写下来的片段会留给未来回看
        </p>
      </div>
      <div>
        <p class="date-pill">{{ today }}</p>
      </div>
    </div>

    <!-- 统计卡片 -->
    <div class="today-grid">
      <div class="surface note-card accent">
        <h3 class="section-heading"><h2>聊聊</h2></h3>
        <p>记录了 {{ messageCount }} 条对话</p>
        <p>最近一条：{{ lastMessage }}</p>
        <button class="note-action" @click="$router.push('/chat')">开始聊聊 →</button>
      </div>

      <div class="surface note-card">
        <h3 class="section-heading"><h2>留存</h2></h3>
        <p>已收藏 {{ recordCount }} 条记录</p>
        <p>{{ recordHint }}</p>
        <button class="note-action ghost" @click="$router.push('/records')">看看留存 →</button>
      </div>

      <div class="surface note-card">
        <h3 class="section-heading"><h2>回望</h2></h3>
        <p>有 {{ memoryCount }} 条长期记忆</p>
        <p>它们在等未来的你翻开</p>
        <button class="note-action ghost" @click="$router.push('/review')">翻开回望 →</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useChatStore } from '../stores/chat'

const chat = useChatStore()

const today = computed(() => {
  const d = new Date()
  return `${d.getMonth() + 1}月${d.getDate()}日 ${['日','一','二','三','四','五','六'][d.getDay()]}`
})

const messageCount = computed(() => chat.messages.length)
const lastMessage = computed(() => {
  if (!chat.messages.length) return '还没有开始'
  const last = chat.messages[chat.messages.length - 1]
  return last.content.slice(0, 20) + (last.content.length > 20 ? '…' : '')
})

const recordCount = ref(0)
const recordHint = computed(() =>
  recordCount.value ? '每一条都是时间的切片' : '记录会慢慢沉淀成纸片'
)

const memoryCount = ref(0)
</script>
