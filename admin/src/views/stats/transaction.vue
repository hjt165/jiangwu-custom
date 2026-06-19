<template>
  <div class="stats-transaction">
    <div class="page-header">
      <h2>交易统计</h2>
    </div>

    <el-row :gutter="20" class="stat-cards">
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value">¥{{ formatAmount(stats.totalAmount) }}</div>
            <div class="stat-label">总交易额</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value">{{ stats.orderCount }}</div>
            <div class="stat-label">总订单数</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value">¥{{ formatAmount(stats.avgOrderAmount) }}</div>
            <div class="stat-label">平均客单价</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value">{{ stats.completionRate }}%</div>
            <div class="stat-label">完成率</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20">
      <el-col :span="16">
        <el-card>
          <template #header>交易趋势</template>
          <div ref="trendChartRef" style="height: 400px"></div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card>
          <template #header>订单状态分布</template>
          <div ref="pieChartRef" style="height: 400px"></div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onBeforeUnmount, nextTick } from 'vue'
import * as echarts from 'echarts'
import { getTransactionStats } from '@/api/stats'

const trendChartRef = ref(null)
const pieChartRef = ref(null)
let trendChart = null
let pieChart = null

const stats = reactive({
  totalAmount: 0,
  orderCount: 0,
  completedCount: 0,
  avgOrderAmount: 0,
  completionRate: 0
})

const formatAmount = (val) => {
  if (!val) return '0'
  return Number(val).toLocaleString('zh-CN', { maximumFractionDigits: 0 })
}

const initTrendChart = (trendData) => {
  if (!trendChartRef.value) return
  trendChart = echarts.init(trendChartRef.value)
  
  const months = trendData?.months || []
  const orderData = trendData?.orderCounts || []
  const amountData = trendData?.amounts || []

  trendChart.setOption({
    tooltip: {
      trigger: 'axis',
      axisPointer: { type: 'cross' }
    },
    legend: {
      data: ['订单数', '交易额'],
      bottom: 0
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '15%',
      top: '5%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: months
    },
    yAxis: [
      {
        type: 'value',
        name: '订单数',
        position: 'left'
      },
      {
        type: 'value',
        name: '交易额(¥)',
        position: 'right'
      }
    ],
    series: [
      {
        name: '订单数',
        type: 'bar',
        data: orderData,
        itemStyle: { color: '#3498DB' },
        barWidth: '30%'
      },
      {
        name: '交易额',
        type: 'line',
        yAxisIndex: 1,
        data: amountData,
        itemStyle: { color: '#E74C3C' },
        smooth: true
      }
    ]
  })
}

const initPieChart = (statusData) => {
  if (!pieChartRef.value) return
  pieChart = echarts.init(pieChartRef.value)

  pieChart.setOption({
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c} ({d}%)'
    },
    legend: {
      orient: 'vertical',
      left: 'left',
      top: 'center'
    },
    series: [
      {
        name: '订单状态',
        type: 'pie',
        radius: ['40%', '70%'],
        center: ['60%', '50%'],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 6,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          show: false,
          position: 'center'
        },
        emphasis: {
          label: {
            show: true,
            fontSize: 16,
            fontWeight: 'bold'
          }
        },
        labelLine: { show: false },
        data: statusData || [
          { value: 0, name: '已完成', itemStyle: { color: '#27AE60' } },
          { value: 0, name: '制作中', itemStyle: { color: '#3498DB' } },
          { value: 0, name: '待支付', itemStyle: { color: '#F39C12' } },
          { value: 0, name: '已取消', itemStyle: { color: '#95A5A6' } },
          { value: 0, name: '争议中', itemStyle: { color: '#E74C3C' } }
        ]
      }
    ]
  })
}

const fetchData = async () => {
  try {
    const res = await getTransactionStats()
    const data = res.data || res
    stats.totalAmount = data.totalAmount || 0
    stats.orderCount = data.orderCount || 0
    stats.completedCount = data.completedCount || 0
    stats.avgOrderAmount = data.orderCount > 0 
      ? Math.round((data.totalAmount || 0) / data.orderCount) 
      : 0
    stats.completionRate = data.orderCount > 0 
      ? Math.round((data.completedCount || 0) / data.orderCount * 100) 
      : 0
    return data
  } catch (e) {
    console.error('获取交易统计失败:', e)
    return {}
  }
}

const handleResize = () => {
  trendChart?.resize()
  pieChart?.resize()
}

onMounted(async () => {
  const data = await fetchData()
  await nextTick()
  initTrendChart(data.trendData)
  initPieChart(data.statusDistribution)
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  trendChart?.dispose()
  pieChart?.dispose()
})
</script>

<style lang="scss" scoped>
.stat-cards { margin-bottom: 20px; }
.stat-item { text-align: center; padding: 10px 0; }
.stat-value { font-size: 28px; font-weight: 700; color: #2C3E50; }
.stat-label { font-size: 13px; color: #909399; margin-top: 8px; }
.page-header { margin-bottom: 20px; h2 { margin: 0; color: #2C3E50; } }
</style>
