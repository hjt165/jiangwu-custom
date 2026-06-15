<template>
  <div class="order-detail">
    <div class="page-header">
      <h2>订单详情</h2>
      <el-button @click="$router.back()">返回</el-button>
    </div>

    <el-row :gutter="20">
      <el-col :span="16">
        <el-card>
          <template #header>订单信息</template>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="订单号">{{ order.orderNo }}</el-descriptions-item>
            <el-descriptions-item label="状态">
              <el-tag :type="getStatusType(order.status)">{{ order.status }}</el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="用户">{{ order.userName }}</el-descriptions-item>
            <el-descriptions-item label="手作人">{{ order.artisanName }}</el-descriptions-item>
            <el-descriptions-item label="金额">¥{{ order.totalAmount }}</el-descriptions-item>
            <el-descriptions-item label="创建时间">{{ order.createdAt }}</el-descriptions-item>
          </el-descriptions>
        </el-card>

        <el-card style="margin-top: 20px">
          <template #header>阶段进度</template>
          <el-timeline>
            <el-timeline-item v-for="stage in order.stages" :key="stage.id" :type="stage.completed ? 'success' : 'primary'" :timestamp="stage.time">
              {{ stage.name }}
            </el-timeline-item>
          </el-timeline>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card>
          <template #header>操作</template>
          <el-space direction="vertical" fill>
            <el-button type="primary" block>查看详情</el-button>
            <el-button type="warning" block>联系用户</el-button>
            <el-button type="danger" block>取消订单</el-button>
          </el-space>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { getOrderDetail } from '@/api/order'

const route = useRoute()
const order = ref({})

const statusMap = {
  pending_payment: { label: '待支付', type: 'warning' },
  paid: { label: '已支付', type: 'primary' },
  producing: { label: '制作中', type: '' },
  completed: { label: '已完成', type: 'success' },
  cancelled: { label: '已取消', type: 'info' },
}

function getStatusType(status) {
  return statusMap[status]?.type || 'info'
}

function getStatusLabel(status) {
  return statusMap[status]?.label || status
}

async function loadOrder() {
  try {
    const res = await getOrderDetail(route.params.id)
    order.value = res.data || {}
  } catch (e) {
    console.error('加载订单详情失败:', e)
  }
}

onMounted(loadOrder)
</script>
