import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

const API_BASE = '/api'

export const useChatStore = defineStore('chat', () => {
  const messages = ref([])
  const pending = ref(false)
  const connected = ref(true)

  const history = computed(() =>
    messages.value.map(m => ({ role: m.role, content: m.content }))
  )

  async function send(text) {
    if (!text.trim() || pending.value) return

    // 用户消息
    messages.value.push({ role: 'user', content: text, time: new Date() })
    pending.value = true

    try {
      const res = await fetch(`${API_BASE}/chat/`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message: text,
          history: history.value.slice(0, -1), // 不包含刚发的这条
        }),
      })
      const data = await res.json()
      messages.value.push({ role: 'assistant', content: data.reply, time: new Date() })
      saveHistory()
    } catch {
      messages.value.push({
        role: 'assistant',
        content: '今天先休息吧，改天再继续聊。记住，你值得被好好陪伴。',
        time: new Date(),
      })
      connected.value = false
    } finally {
      pending.value = false
    }
  }

  function saveHistory() {
    try {
      localStorage.setItem('youwo_messages', JSON.stringify(messages.value.slice(-50)))
    } catch {}
  }

  function loadHistory() {
    try {
      const saved = localStorage.getItem('youwo_messages')
      if (saved) messages.value = JSON.parse(saved)
    } catch {}
  }

  function clearHistory() {
    messages.value = []
    saveHistory()
  }

  return { messages, pending, connected, send, clearHistory }
})
