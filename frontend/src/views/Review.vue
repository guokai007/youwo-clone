<template>
  <div>
    <div class="topbar">
      <div>
        <h1>回望</h1>
        <p class="topbar-lead">翻开一封回信，看看走过的路。</p>
      </div>
    </div>

    <div class="surface" style="padding: 22px;">
      <p class="section-copy" style="margin-bottom: 20px;">
        游我会定期把反复出现的事，整理成一封简短的信，留在回望里。
        等未来的你打开。
      </p>

      <div v-if="memories.length" class="readonly-grid">
        <div v-for="m in memories" :key="m.id" class="readonly-card reflection-card">
          <p style="margin: 0; line-height: 1.7; font-size: 0.95rem;">{{ m.content }}</p>
          <em style="justify-self: end; color: var(--leaf); font-size: 0.75rem; margin-top: 12px;">
            {{ formatDate(m.created_at) }}
          </em>
        </div>
      </div>

      <div v-else class="empty-state">
        <h3>还没有回信</h3>
        <p>当对话中反复出现的话题被识别，你会在这里看到游我写给你的信。</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const memories = ref([])

onMounted(() => {
  try {
    const saved = localStorage.getItem('youwo_memories')
    if (saved) memories.value = JSON.parse(saved)
  } catch {}
})

function formatDate(iso) {
  const d = new Date(iso)
  return `${d.getFullYear()}/${d.getMonth() + 1}/${d.getDate()}`
}
</script>

<style scoped>
.readonly-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
}
.reflection-card {
  position: relative;
  display: grid;
  width: 100%;
  min-height: 104px;
  gap: 9px;
  padding: 14px;
  overflow: hidden;
  border: 1px solid rgba(215, 181, 109, 0.34);
  border-radius: 3px 12px 12px 3px;
  background:
    linear-gradient(90deg, rgba(217, 130, 104, 0.24) 0 3px, transparent 3px),
    repeating-linear-gradient(0deg, transparent 0 25px, rgba(49, 91, 89, 0.06) 26px),
    linear-gradient(145deg, #fffcebf2, #fff8e1bd);
  color: var(--ink);
  text-align: left;
  box-shadow: 0 10px 24px rgba(92, 74, 45, 0.09);
}
.reflection-card::before {
  position: absolute;
  top: -7px;
  left: 50%;
  width: 54px;
  height: 17px;
  border: 1px solid rgba(215, 181, 109, 0.14);
  border-radius: 3px;
  background: repeating-linear-gradient(90deg, rgba(215, 181, 109, 0.12) 0 1px, transparent 1px 7px), rgba(255, 255, 255, 0.58);
  box-shadow: 0 1px 6px rgba(92, 74, 45, 0.12);
  content: "";
  transform: translate(-50%) rotate(-2deg);
}
@media (max-width: 860px) {
  .readonly-grid { grid-template-columns: 1fr; }
}
</style>
