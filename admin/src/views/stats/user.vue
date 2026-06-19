<template>
  <div class="stats-user">
    <div class="page-header">
      <h2>用户行为分析</h2>
    </div>

    <el-row :gutter="20" class="stat-cards">
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value">{{ stats.totalUsers }}</div>
            <div class="stat-label">注册用户</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value">{{ stats.activeUsers }}</div>
            <div class="stat-label">活跃用户</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value">{{ stats.retentionRate }}%</div>
            <div class="stat-label">留存率</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <div class="stat-value">¥{{ stats.avgOrderAmount }}</div>
            <div class="stat-label">平均客单价</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20">
      <el-col :span="12">
        <el-card>
          <template #header>用户增长趋势</template>
          <div ref="growthChartRef" style="height: 350px"></div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card>
          <template #header>用户构成</template>
          <div ref="composeChartRef" style="height: 350px"></div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onBeforeUnmount, nextTick } from 'vue'
import * as echarts from 'echarts'
import { getUserStats } from '@/api/stats'

const growthChartRef = ref(null)
const composeChartRef = ref(null)
let growthChart = null
let composeChart = null

const stats = reactive({
  totalUsers: 0,
  activeUsers: 0,
  newUsers: 0,
  retentionRate: 0,
  avgOrderAmount: 0
})

const initGrowthChart = (growthData) => {
  if (!growthChartRef.value) return
  growthChart = echarts.init(growthChartRef.value)

  const days = growthData?.days || []
  const data = growthData?.values || []

  growthChart.setOption({
    tooltip: {
      trigger: 'axis',
      axisPointer: { type: 'shadow' }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      top: '10%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: days,
      axisLabel: {
        rotate: 45,
        fontSize: 10
      }
    },
    yAxis: {
      type: 'value',
      name: '新增用户'
    },
    series: [
      {
        name: '新增用户',
        type: 'bar',
        data: data,
        itemStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: '#3498DB' },
            { offset: 1, color: '#85C1E9' }
          ]),
          borderRadius: [4, 4, 0, 0]
        },
        barWidth: '60%'
      }
    ]
  })
}

const initComposeChart = (roleData) => {
  if (!composeChartRef.value) return
  composeChart = echarts.init(composeChartRef.value)

  composeChart.setOption({
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
        name: '用户角色',
        type: 'pie',
        radius: ['35%', '65%'],
        center: ['60%', '50%'],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 8,
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
        data: roleData || [
          { value: 0, name: '普通用户', itemStyle: { color: '#3498DB' } },
          { value: 0, name: '手作人', itemStyle: { color: '#E74C3C' } },
          { value: 0, name: '管理员', itemStyle: { color: '#F39C12' } }
        ]
      }
    ]
  })
}

const fetchData = async () => {
  try {
    const res = await getUserStats()
    const data = res.data || res
    stats.totalUsers = data.totalUsers || 0
    stats.activeUsers = data.activeUsers || 0
    stats.newUsers = data.newUsers || 0
    stats.retentionRate = data.retentionRate || 0
    stats.avgOrderAmount = data.avgOrderAmount || 0
    return data
  } catch (e) {
    console.error('获取用户统计失败:', e)
    return {}
  }
}

const handleResize = () => {
  growthChart?.resize()
  composeChart?.resize()
}

onMounted(async () => {
  const data = await fetchData()
  await nextTick()
  initGrowthChart(data.growthTrend)
  initComposeChart(data.roleDistribution)
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  growthChart?.dispose()
  composeChart?.dispose()
})
</script>

<style lang="scss" scoped>
.stat-cards { margin-bottom: 20px; }
.stat-item { text-align: center; padding: 10px 0; }
.stat-value { font-size: 28px; font-weight: 700; color: #2C3E50; }
.stat-label { font-size: 13px; color: #909399; margin-top: 8px; }
.page-header { margin-bottom: 20px; h2 { margin: 0; color: #2C3E50; } }
</style>
