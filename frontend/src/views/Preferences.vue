<template>
  <div>
    <div class="topbar">
      <div>
        <h1>偏好</h1>
        <p class="topbar-lead">调整游我陪伴你的方式。</p>
      </div>
    </div>

    <div class="preference-section">
      <h2>身份</h2>
      <div class="preference-row">
        <div class="preference-label">
          <strong>称呼</strong>
          <span>游我会怎么叫你</span>
        </div>
        <input
          v-model="identity"
          @change="savePrefs"
          placeholder="给自己起个名字"
          style="min-height:36px; border:1px solid var(--line); border-radius:999px; padding:0 14px; background:rgba(255,255,255,0.8); width: 200px;"
        />
      </div>
    </div>

    <div class="preference-section">
      <h2>陪伴方式</h2>
      <div class="preference-row">
        <div class="preference-label">
          <strong>温暖模式</strong>
          <span>更温柔的回应方式</span>
        </div>
        <button
          class="toggle"
          :class="{ active: prefs.warm }"
          @click="prefs.warm = !prefs.warm; savePrefs()"
        ></button>
      </div>
      <div class="preference-row">
        <div class="preference-label">
          <strong>主动问好</strong>
          <span>每天打开时主动问候</span>
        </div>
        <button
          class="toggle"
          :class="{ active: prefs.greet }"
          @click="prefs.greet = !prefs.greet; savePrefs()"
        ></button>
      </div>
      <div class="preference-row">
        <div class="preference-label">
          <strong>记忆沉淀</strong>
          <span>允许 AI 总结对话形成记忆</span>
        </div>
        <button
          class="toggle"
          :class="{ active: prefs.memory }"
          @click="prefs.memory = !prefs.memory; savePrefs()"
        ></button>
      </div>
    </div>

    <div class="preference-section">
      <h2>数据</h2>
      <div class="preference-row">
        <div class="preference-label">
          <strong>本地模式</strong>
          <span>所有数据存在本地浏览器</span>
        </div>
        <span style="color: var(--leaf); font-size: 0.85rem;">已开启 ✓</span>
      </div>
      <div class="preference-row">
        <div class="preference-label">
          <strong>导出数据</strong>
          <span>下载所有聊天记录和记忆</span>
        </div>
        <button class="note-action ghost" style="font-size: 0.82rem; min-height: 30px;" @click="exportData">
          导出
        </button>
      </div>
      <div class="preference-row">
        <div class="preference-label">
          <strong>清空所有</strong>
          <span>删除所有本地数据</span>
        </div>
        <button class="note-action ghost" style="font-size: 0.82rem; min-height: 30px; color: var(--sunset); border-color: rgba(217,130,104,0.3);" @click="clearAll">
          清空
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const identity = ref('')
const prefs = ref({ warm: true, greet: true, memory: true })

onMounted(() => {
  try {
    const saved = localStorage.getItem('youwo_prefs')
    if (saved) {
      const p = JSON.parse(saved)
      identity.value = p.identity || ''
      prefs.value = { ...prefs.value, ...p }
    }
  } catch {}
})

function savePrefs() {
  try {
    localStorage.setItem('youwo_prefs', JSON.stringify({
      identity: identity.value,
      ...prefs.value,
    }))
  } catch {}
}

function exportData() {
  const data = {
    identity: identity.value,
    prefs: prefs.value,
    messages: JSON.parse(localStorage.getItem('youwo_messages') || '[]'),
    records: JSON.parse(localStorage.getItem('youwo_records') || '[]'),
    memories: JSON.parse(localStorage.getItem('youwo_memories') || '[]'),
    exported_at: new Date().toISOString(),
  }
  const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `youwo-backup-${new Date().toISOString().slice(0, 10)}.json`
  a.click()
  URL.revokeObjectURL(url)
}

function clearAll() {
  if (confirm('确定清空所有数据？此操作不可恢复。')) {
    localStorage.removeItem('youwo_messages')
    localStorage.removeItem('youwo_records')
    localStorage.removeItem('youwo_memories')
    localStorage.removeItem('youwo_prefs')
    identity.value = ''
    prefs.value = { warm: true, greet: true, memory: true }
  }
}
</script>
