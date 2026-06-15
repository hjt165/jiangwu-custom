<template>
  <div class="stats-user">
    <div class="page-header">
      <h2>用户行为分析</h2>
    </div>

    <el-row :gutter="20" class="stat-cards">
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value">1,280</div>
            <div class="stat-label">注册用户</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value">456</div>
            <div class="stat-label">日活用户</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value">68%</div>
            <div class="stat-label">转化率</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value">4.6</div>
            <div class="stat-label">平均评分</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20">
      <el-col :span="12">
        <el-card>
          <template #header>用户来源</template>
          <div ref="sourceChartRef" style="height: 300px"></div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card>
          <template #header>活跃时段</template>
          <div ref="activeChartRef" style="height: 300px"></div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const sourceChartRef = ref(null)
const activeChartRef = ref(null)

onMounted(() => {
  console.log('用户行为分析图表初始化')
})
</script>

<style lang="scss" scoped>
.stat-cards { margin-bottom: 20px; }
.stat-item { text-align: center; padding: 10px 0; }
.stat-value { font-size: 28px; font-weight: 700; color: #2C3E50; }
.stat-label { font-size: 13px; color: #909399; margin-top: 8px; }
</style>
