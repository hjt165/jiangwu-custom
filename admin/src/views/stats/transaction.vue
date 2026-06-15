<template>
  <div class="stats-transaction">
    <div class="page-header">
      <h2>交易统计</h2>
    </div>

    <el-row :gutter="20" class="stat-cards">
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value">¥128,960</div>
            <div class="stat-label">总交易额</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value">356</div>
            <div class="stat-label">总订单数</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value">¥362</div>
            <div class="stat-label">平均客单价</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value">92%</div>
            <div class="stat-label">完成率</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-card>
      <template #header>交易趋势</template>
      <div ref="chartRef" style="height: 400px"></div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const chartRef = ref(null)

onMounted(() => {
  // ECharts 图表初始化（需安装 echarts）
  console.log('交易统计图表初始化')
})
</script>

<style lang="scss" scoped>
.stat-cards { margin-bottom: 20px; }
.stat-item { text-align: center; padding: 10px 0; }
.stat-value { font-size: 28px; font-weight: 700; color: #2C3E50; }
.stat-label { font-size: 13px; color: #909399; margin-top: 8px; }
</style>
