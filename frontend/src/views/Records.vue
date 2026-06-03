<template>
  <div>
    <div class="topbar">
      <div>
        <h1>留存</h1>
        <p class="topbar-lead">时间的纸片，散落在岁月里。</p>
      </div>
    </div>

    <div class="surface records-card">
      <!-- 快捷输入 -->
      <div class="composer" style="margin-bottom: 20px;">
        <textarea v-model="newContent" placeholder="写下一段此刻…" rows="2"></textarea>
        <button @click="addRecord" :disabled="!newContent.trim()">留存</button>
      </div>

      <!-- 记录列表 -->
      <ul class="record-list" v-if="records.length">
        <li v-for="r in records" :key="r.id" class="record-item">
          <div class="record-meta">
            <span class="record-date">{{ formatDate(r.created_at) }}</span>
            <span class="record-source">{{ r.source }}</span>
          </div>
          <div>
            <p class="record-content">{{ r.content }}</p>
            <div class="record-tags">
              <span v-for="tag in r.tags" :key="tag">{{ tag }}</span>
            </div>
          </div>
        </li>
      </ul>

      <div v-else class="empty-state">
        <h3>还没有留存</h3>
        <p>写下的每一段，都会成为时间的纸片。</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const records = ref([])
const newContent = ref('')

onMounted(() => {
  try {
    const saved = localStorage.getItem('youwo_records')
    if (saved) records.value = JSON.parse(saved)
  } catch {}
})

function addRecord() {
  if (!newContent.value.trim()) return
  records.value.unshift({
    id: Date.now().toString(),
    content: newContent.value.trim(),
    tags: [],
    source: '手记',
    created_at: new Date().toISOString(),
  })
  newContent.value = ''
  saveRecords()
}

function saveRecords() {
  try {
    localStorage.setItem('youwo_records', JSON.stringify(records.value))
  } catch {}
}

function formatDate(iso) {
  const d = new Date(iso)
  return `${d.getMonth() + 1}/${d.getDate()} ${d.getHours().toString().padStart(2,'0')}:${d.getMinutes().toString().padStart(2,'0')}`
}
</script>
