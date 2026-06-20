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
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-icon" style="background: #e8f4fd">
              <el-icon :size="28" color="#3498DB"><User /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.totalUsers }}</div>
              <div class="stat-label">用户总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-icon" style="background: #fef0e6">
              <el-icon :size="28" color="#E67E22"><Document /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.totalOrders }}</div>
              <div class="stat-label">订单总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-icon" style="background: #e8fae8">
              <el-icon :size="28" color="#27AE60"><Money /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">¥{{ stats.totalRevenue }}</div>
              <div class="stat-label">总交易额</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-icon" style="background: #f0e8fd">
              <el-icon :size="28" color="#9B59B6"><Star /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.totalArtisans }}</div>
              <div class="stat-label">手作人数</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20">
      <el-col :span="16">
        <el-card>
          <template #header>待办事项</template>
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
        <el-card>
          <template #header>快捷操作</template>
          <div class="quick-actions">
            <el-button type="primary" @click="$router.push('/user/list')">用户管理</el-button>
            <el-button type="warning" @click="$router.push('/order/list')">订单管理</el-button>
            <el-button type="success" @click="$router.push('/content/image')">图片审核</el-button>
            <el-button type="info" @click="$router.push('/stats/transaction')">数据统计</el-button>
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
    // 使用默认数据作为fallback
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
  margin-bottom: 20px;
}

.stat-cards {
  margin-bottom: 20px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.stat-value {
  font-size: 24px;
  font-weight: 700;
  color: #303133;
}

.stat-label {
  font-size: 13px;
  color: #909399;
  margin-top: 4px;
}

.quick-actions {
  display: flex;
  flex-direction: column;
  gap: 12px;

  .el-button {
    width: 100%;
  }
}
</style>
