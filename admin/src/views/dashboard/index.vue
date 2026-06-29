<template>
  <div class="dashboard-page">
    <!-- 顶部统计卡片 -->
    <div class="stats-grid">
      <div class="stat-card" v-for="item in statItems" :key="item.key" :class="'stat-' + item.key">
        <div class="stat-icon-wrap">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" class="stat-icon">
            <path v-if="item.key === 'users'" d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/>
            <circle v-if="item.key === 'users'" cx="9" cy="7" r="4"/>
            <path v-if="item.key === 'orders'" d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4Z"/>
            <path v-if="item.key === 'orders'" d="M3 6h18"/>
            <path v-if="item.key === 'orders'" d="M16 10a4 4 0 0 1-8 0"/>
            <path v-if="item.key === 'revenue'" d="M12 2v20m1-17h.01M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>
            <path v-if="item.key === 'artisans'" d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
            <circle v-if="item.key === 'artisans'" cx="8.5" cy="7" r="4"/>
            <path v-if="item.key === 'artisans'" d="M20 8v6m-3-3h6"/>
          </svg>
        </div>
        <div class="stat-info">
          <div class="stat-value">{{ item.display }}</div>
          <div class="stat-label">{{ item.label }}</div>
        </div>
      </div>
    </div>

    <!-- 下半部分 -->
    <div class="bottom-section">
      <!-- 待办事项 -->
      <div class="panel todo-panel">
        <div class="panel-header">
          <span class="panel-title">待处理事项</span>
          <span class="panel-action" @click="$router.push('/order/list')">查看全部</span>
        </div>
        <div class="todo-list">
          <div v-if="!todoList.length" class="empty-state">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
              <path d="M9 12h6m-3-3v6m-7 4h14a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2Z"/>
            </svg>
            <span>暂无待处理事项</span>
          </div>
          <div v-else class="todo-items">
            <div class="todo-item" v-for="(todo, idx) in todoList" :key="idx">
              <div class="todo-dot" ></div>
              <div class="todo-content">
                <span class="todo-type">{{ todo.type }}</span>
                <span class="todo-detail">{{ todo.content }}</span>
              </div>
              <div class="todo-meta">
                <span class="todo-time">{{ todo.time }}</span>
                <span class="todo-action" @click="handleTodoAction(todo)">处理</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 快捷入口 -->
      <div class="panel shortcut-panel">
        <div class="panel-header">
          <span class="panel-title">快捷入口</span>
        </div>
        <div class="shortcut-grid">
          <div class="shortcut-card" v-for="s in shortcuts" :key="s.path" @click="$router.push(s.path)">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" class="shortcut-icon">
              <path v-if="s.label === '用户管理'" d="M15 19.128a9.38 9.38 0 0 0 2.625.372 9.337 9.337 0 0 0 4.121-.952 4.125 4.125 0 0 0-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 0 1 8.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0 1 11.964-3.07M12 6.375a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0Zm8.25 2.25a2.625 2.625 0 1 1-5.25 0 2.625 2.625 0 0 1 5.25 0Z"/>
              <path v-if="s.label === '订单管理'" d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4ZM3 6h18M16 10a4 4 0 0 1-8 0"/>
              <path v-if="s.label === '图片审核'" d="M2.25 15.75l5.159-5.159a2.25 2.25 0 013.182 0l5.159 5.159m-1.5-1.5l1.409-1.409a2.25 2.25 0 013.182 0l2.909 2.909M3.75 21h16.5A2.25 2.25 0 0022.5 18.75V5.25A2.25 2.25 0 0020.25 3H3.75A2.25 2.25 0 001.5 5.25v13.5A2.25 2.25 0 003.75 21zM8.25 8.625a1.125 1.125 0 100-2.25 1.125 1.125 0 000 2.25z"/>
              <path v-if="s.label === '交易统计'" d="M3 13.125C3 12.504 3.504 12 4.125 12h2.25c.621 0 1.125.504 1.125 1.125v6.75C7.5 20.496 6.996 21 6.375 21h-2.25A1.125 1.125 0 013 19.875v-6.75zM9.75 8.625c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125v11.25c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 01-1.125-1.125V8.625zM16.5 4.125c0-.621.504-1.125 1.125-1.125h2.25C20.496 3 21 3.504 21 4.125v15.75c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 01-1.125-1.125V4.125z"/>
            </svg>
            <span class="shortcut-label">{{ s.label }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getDashboardData } from '@/api/stats'

const router = useRouter()
const loading = ref(false)
const todoList = ref([])

const stats = reactive({
  totalUsers: 0,
  totalOrders: 0,
  totalRevenue: '0',
  totalArtisans: 0,
})

const statItems = computed(() => [
  { key: 'users', label: '用户总数', display: stats.totalUsers },
  { key: 'orders', label: '订单总数', display: stats.totalOrders },
  { key: 'revenue', label: '总交易额', display: `¥${stats.totalRevenue}` },
  { key: 'artisans', label: '手作人数量', display: stats.totalArtisans },
])

const shortcuts = [
  { label: '用户管理', path: '/user/list' },
  { label: '订单管理', path: '/order/list' },
  { label: '图片审核', path: '/content/image' },
  { label: '交易统计', path: '/stats/transaction' },
]

const fetchDashboardData = async () => {
  loading.value = true
  try {
    const res = await getDashboardData()
    if (res.code === 200 && res.data) {
      Object.assign(stats, res.data || {})
      todoList.value = res.data.todoList || []
    }
  } catch (error) {
    console.error('获取仪表盘数据失败:', error)
  } finally {
    loading.value = false
  }
}

function handleTodoAction(row) {
  router.push('/order/list')
}

onMounted(() => {
  fetchDashboardData()
})
</script>

<style lang="scss" scoped>
.dashboard-page {
  padding: 20px 24px;
  min-height: 100%;
}

/* ========== 统计卡片 ========== */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 14px;
  margin-bottom: 18px;
}

.stat-card {
  background: #fff;
  border-radius: 8px;
  padding: 16px 18px;
  display: flex;
  align-items: center;
  gap: 14px;
  border: 1px solid #F0F0F0;
  transition: all 0.2s ease;

  &:hover {
    box-shadow: 0 4px 12px rgba(44, 62, 80, 0.08);
    transform: translateY(-1px);
  }

  &.stat-users {
    .stat-icon-wrap { background: #EBF5FB; color: #2980B9; }
  }
  &.stat-orders {
    .stat-icon-wrap { background: #FEF9E7; color: #E67E22; }
  }
  &.stat-revenue {
    .stat-icon-wrap { background: #E8F8F5; color: #27AE60; }
  }
  &.stat-artisans {
    .stat-icon-wrap { background: #F5EEF8; color: #8E44AD; }
  }
}

.stat-icon-wrap {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;

  .stat-icon {
    width: 20px;
    height: 20px;
  }
}

.stat-info {
  flex: 1;
  min-width: 0;
}

.stat-value {
  font-size: 22px;
  font-weight: 700;
  color: #2C3E50;
  line-height: 1.2;
  font-variant-numeric: tabular-nums;
}

.stat-label {
  font-size: 12px;
  color: #909399;
  margin-top: 2px;
}

/* ========== 下半部分 ========== */
.bottom-section {
  display: grid;
  grid-template-columns: 1.4fr 1fr;
  gap: 14px;
}

.panel {
  background: #fff;
  border-radius: 8px;
  border: 1px solid #F0F0F0;
  padding: 18px 20px;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 14px;
}

.panel-title {
  font-size: 14px;
  font-weight: 600;
  color: #2C3E50;
}

.panel-action {
  font-size: 12px;
  color: #3498DB;
  cursor: pointer;
  transition: color 0.2s;

  &:hover {
    color: #2980B9;
  }
}

/* ========== 待办列表 ========== */
.todo-list {
  min-height: 180px;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 180px;
  color: #C0C4CC;
  gap: 8px;

  svg {
    width: 36px;
    height: 36px;
    opacity: 0.5;
  }

  span {
    font-size: 13px;
  }
}

.todo-items {
  display: flex;
  flex-direction: column;
}

.todo-item {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  padding: 10px 0;
  border-bottom: 1px solid #F5F5F5;

  &:last-child {
    border-bottom: none;
  }
}

.todo-dot {
  width: 5px;
  height: 5px;
  border-radius: 50%;
  background: #DCDFE6;
  margin-top: 7px;
  flex-shrink: 0;

  &--first {
    background: #E74C3C;
  }
}

.todo-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 3px;
  min-width: 0;
}

.todo-type {
  font-size: 11px;
  color: #C0C4CC;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.todo-detail {
  font-size: 13px;
  color: #303133;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.todo-meta {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-shrink: 0;
}

.todo-time {
  font-size: 11px;
  color: #C0C4CC;
  white-space: nowrap;
}

.todo-action {
  font-size: 12px;
  color: #3498DB;
  cursor: pointer;
  padding: 2px 6px;
  border-radius: 3px;
  transition: all 0.2s;

  &:hover {
    background: #EBF5FB;
    color: #2980B9;
  }
}

/* ========== 快捷入口 ========== */
.shortcut-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

.shortcut-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 20px 12px;
  border-radius: 8px;
  border: 1px solid #F0F0F0;
  cursor: pointer;
  transition: all 0.2s ease;

  &:hover {
    border-color: #2C3E50;
    background: #FAFAF9;
    transform: translateY(-1px);
    box-shadow: 0 2px 8px rgba(44, 62, 80, 0.06);
  }

  .shortcut-icon {
    width: 24px;
    height: 24px;
    color: #909399;
    transition: color 0.2s;
  }

  .shortcut-label {
    font-size: 13px;
    color: #606266;
    transition: color 0.2s;
  }

  &:hover {
    .shortcut-icon { color: #2C3E50; }
    .shortcut-label { color: #2C3E50; font-weight: 500; }
  }
}
</style>