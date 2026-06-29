<template>
  <div class="dashboard" v-loading="loading">
    <div class="page-header">
      <div>
        <h2>概览</h2>
        <p class="page-desc">平台运营关键指标</p>
      </div>
      <el-button @click="fetchDashboardData" :loading="loading" class="refresh-btn">
        <el-icon><Refresh /></el-icon>
        刷新
      </el-button>
    </div>

    <!-- 统计行 -->
    <div class="stat-row">
      <div class="stat-item" v-for="item in statItems" :key="item.key">
        <div class="stat-value">{{ item.display }}</div>
        <div class="stat-label">{{ item.label }}</div>
      </div>
    </div>

    <div class="content-row">
      <!-- 待办事项 -->
      <div class="panel">
        <div class="panel-header">
          <span>待处理事项</span>
          <el-link type="primary" @click="$router.push('/order/list')">查看全部</el-link>
        </div>
        <el-table :data="todoList" class="todo-table">
          <el-table-column prop="type" label="类型" width="100" />
          <el-table-column prop="content" label="内容" />
          <el-table-column prop="time" label="时间" width="180" />
          <el-table-column label="操作" width="80">
            <template #default="{ row }">
              <el-link type="primary" @click="handleTodoAction(row)">处理</el-link>
            </template>
          </el-table-column>
        </el-table>
        <div v-if="!todoList.length" class="empty-tip">暂无待处理事项</div>
      </div>

      <!-- 快捷入口 -->
      <div class="panel">
        <div class="panel-header">
          <span>快捷入口</span>
        </div>
        <div class="shortcuts">
          <div
            v-for="s in shortcuts"
            :key="s.path"
            class="shortcut-item"
            @click="$router.push(s.path)"
          >
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
const stats = reactive({
  totalUsers: 0,
  totalOrders: 0,
  totalRevenue: '0',
  totalArtisans: 0,
})
const todoList = ref([])

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
.dashboard {
  padding: 28px 32px;
  background: #FAFAF9;
  min-height: 100%;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 28px;

  h2 {
    font-size: 20px;
    font-weight: 600;
    color: #2C3E50;
    margin: 0;
    letter-spacing: 0.5px;
  }

  .page-desc {
    font-size: 13px;
    color: #909399;
    margin: 4px 0 0;
  }

  .refresh-btn {
    border-radius: 6px;
    background: #fff;
    border: 1px solid #E4E7ED;
    color: #606266;

    &:hover {
      border-color: #2C3E50;
      color: #2C3E50;
    }
  }
}

/* 统计行 */
.stat-row {
  display: flex;
  gap: 1px;
  background: #E4E7ED;
  border-radius: 8px;
  overflow: hidden;
  margin-bottom: 28px;
}

.stat-item {
  flex: 1;
  background: #fff;
  padding: 24px 28px;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.stat-value {
  font-size: 28px;
  font-weight: 700;
  color: #2C3E50;
  line-height: 1.1;
  font-variant-numeric: tabular-nums;
}

.stat-label {
  font-size: 13px;
  color: #909399;
}

/* 内容行 */
.content-row {
  display: flex;
  gap: 1px;
  background: #E4E7ED;
  border-radius: 8px;
  overflow: hidden;
}

.panel {
  flex: 1;
  background: #fff;
  padding: 24px;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  font-size: 15px;
  font-weight: 600;
  color: #303133;
}

.todo-table {
  :deep(.el-table__header) th {
    background: #FAFAF9;
    color: #606266;
    font-weight: 500;
    font-size: 13px;
  }

  :deep(.el-table__row) td {
    font-size: 13px;
  }
}

.empty-tip {
  text-align: center;
  padding: 40px 0;
  color: #C0C4CC;
  font-size: 14px;
}

/* 快捷入口 */
.shortcuts {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 8px;
}

.shortcut-item {
  padding: 16px;
  border: 1px solid #E4E7ED;
  border-radius: 6px;
  text-align: center;
  cursor: pointer;
  transition: all 0.15s;
  font-size: 14px;
  color: #606266;

  &:hover {
    border-color: #2C3E50;
    color: #2C3E50;
    background: #FAFAF9;
  }
}
</style>
