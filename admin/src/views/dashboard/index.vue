<template>
  <div class="dashboard" v-loading="loading">
    <div class="page-header">
      <h2>工作台</h2>
      <el-button type="primary" @click="fetchDashboardData" :loading="loading">
        <el-icon><Refresh /></el-icon>
        刷新
      </el-button>
    </div>

    <el-row :gutter="20" class="stat-cards">
      <el-col :span="6">
        <div class="stat-card stat-card--blue">
          <div class="stat-icon">
            <el-icon :size="24"><User /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.totalUsers }}</div>
            <div class="stat-label">用户总数</div>
          </div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card stat-card--orange">
          <div class="stat-icon">
            <el-icon :size="24"><Document /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.totalOrders }}</div>
            <div class="stat-label">订单总数</div>
          </div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card stat-card--green">
          <div class="stat-icon">
            <el-icon :size="24"><Money /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">¥{{ stats.totalRevenue }}</div>
            <div class="stat-label">总交易额</div>
          </div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card stat-card--purple">
          <div class="stat-icon">
            <el-icon :size="24"><Star /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.totalArtisans }}</div>
            <div class="stat-label">手作人数</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <el-row :gutter="20">
      <el-col :span="16">
        <el-card class="content-card">
          <template #header>
            <div class="card-header">
              <span>待办事项</span>
            </div>
          </template>
          <el-table :data="todoList" stripe>
            <el-table-column prop="type" label="类型" width="120" />
            <el-table-column prop="content" label="内容" />
            <el-table-column prop="time" label="时间" width="180" />
            <el-table-column label="操作" width="100">
              <template #default="{ row }">
                <el-button type="primary" link size="small" @click="handleTodoAction(row)">处理</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card class="content-card">
          <template #header>
            <div class="card-header">
              <span>快捷操作</span>
            </div>
          </template>
          <div class="quick-actions">
            <div class="quick-action-item" @click="$router.push('/user/list')">
              <div class="action-icon action-icon--blue">
                <el-icon><User /></el-icon>
              </div>
              <span>用户管理</span>
            </div>
            <div class="quick-action-item" @click="$router.push('/order/list')">
              <div class="action-icon action-icon--orange">
                <el-icon><Document /></el-icon>
              </div>
              <span>订单管理</span>
            </div>
            <div class="quick-action-item" @click="$router.push('/content/image')">
              <div class="action-icon action-icon--green">
                <el-icon><Picture /></el-icon>
              </div>
              <span>图片审核</span>
            </div>
            <div class="quick-action-item" @click="$router.push('/stats/transaction')">
              <div class="action-icon action-icon--purple">
                <el-icon><DataAnalysis /></el-icon>
              </div>
              <span>数据统计</span>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getDashboardData } from '@/api/stats'

const router = useRouter()

const stats = reactive({
  totalUsers: 0,
  totalOrders: 0,
  totalRevenue: '0',
  totalArtisans: 0,
})

const todoList = ref([])
const loading = ref(false)

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
    stats.totalUsers = 0
    stats.totalOrders = 0
    stats.totalRevenue = '0'
    stats.totalArtisans = 0
    todoList.value = []
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
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;

  h2 {
    font-size: 20px;
    font-weight: 700;
    color: #2C3E50;
  }
}

.stat-cards {
  margin-bottom: 24px;
}

.stat-card {
  background: #fff;
  border-radius: 12px;
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  transition: all 0.3s;
  cursor: default;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
  }

  &--blue .stat-icon { background: #e8f4fd; color: #3498DB; }
  &--orange .stat-icon { background: #fef0e6; color: #E67E22; }
  &--green .stat-icon { background: #e8fae8; color: #27AE60; }
  &--purple .stat-icon { background: #f0e8fd; color: #9B59B6; }
}

.stat-icon {
  width: 52px;
  height: 52px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.stat-value {
  font-size: 28px;
  font-weight: 700;
  color: #2C3E50;
  line-height: 1.2;
}

.stat-label {
  font-size: 13px;
  color: #909399;
  margin-top: 4px;
}

.content-card {
  :deep(.el-card__header) {
    padding: 16px 20px;
    border-bottom: 1px solid #f0f2f5;
  }
}

.card-header {
  font-size: 15px;
  font-weight: 600;
  color: #303133;
}

.quick-actions {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}

.quick-action-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 16px 12px;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s;

  &:hover {
    background: #f5f7fa;
  }

  span {
    font-size: 13px;
    color: #606266;
    font-weight: 500;
  }
}

.action-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;

  &--blue { background: #e8f4fd; color: #3498DB; }
  &--orange { background: #fef0e6; color: #E67E22; }
  &--green { background: #e8fae8; color: #27AE60; }
  &--purple { background: #f0e8fd; color: #9B59B6; }
}
</style>
