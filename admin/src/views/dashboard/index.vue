<template>
  <div class="dashboard">
    <div class="page-header">
      <h2>工作台</h2>
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
                <el-button type="primary" link size="small">处理</el-button>
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
import { ref, reactive } from 'vue'

const stats = reactive({
  totalUsers: 1280,
  totalOrders: 356,
  totalRevenue: '128,960',
  totalArtisans: 45,
})

const todoList = ref([
  { type: '用户认证', content: '张三申请成为手作人', time: '2026-06-14 10:00' },
  { type: '争议处理', content: '订单 JW20260614-001234 有争议', time: '2026-06-14 09:30' },
  { type: '内容审核', content: '3张新图片待审核', time: '2026-06-14 09:00' },
  { type: '评论审核', content: '5条新评论待审核', time: '2026-06-14 08:30' },
])
</script>

<style lang="scss" scoped>
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
