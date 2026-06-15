<template>
  <div class="order-list">
    <div class="page-header">
      <h2>订单列表</h2>
    </div>

    <div class="page-card">
      <div class="search-bar">
        <el-input v-model="searchKeyword" placeholder="搜索订单号" clearable style="width: 200px" />
        <el-select v-model="filterStatus" placeholder="订单状态" clearable style="width: 140px">
          <el-option label="待支付" value="pending_payment" />
          <el-option label="已支付" value="paid" />
          <el-option label="制作中" value="producing" />
          <el-option label="已完成" value="completed" />
          <el-option label="已取消" value="cancelled" />
        </el-select>
        <el-button type="primary" @click="loadData">搜索</el-button>
      </div>

      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="orderNo" label="订单号" width="200" />
        <el-table-column prop="userName" label="用户" width="120" />
        <el-table-column prop="artisanName" label="手作人" width="120" />
        <el-table-column prop="totalAmount" label="金额" width="100">
          <template #default="{ row }">¥{{ row.totalAmount }}</template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="120">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">{{ getStatusLabel(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="创建时间" width="180" />
        <el-table-column label="操作" fixed="right" width="120">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="viewDetail(row.id)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="page"
        :page-size="10"
        :total="total"
        layout="total, prev, pager, next"
        @current-change="loadData"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getOrderList } from '@/api/order'

const router = useRouter()
const loading = ref(false)
const tableData = ref([])
const searchKeyword = ref('')
const filterStatus = ref('')
const page = ref(1)
const total = ref(0)

const statusMap = {
  pending_payment: { label: '待支付', type: 'warning' },
  paid: { label: '已支付', type: 'primary' },
  producing: { label: '制作中', type: '' },
  completed: { label: '已完成', type: 'success' },
  cancelled: { label: '已取消', type: 'info' },
}

function getStatusLabel(status) { return statusMap[status]?.label || status }
function getStatusType(status) { return statusMap[status]?.type || 'info' }

async function loadData() {
  loading.value = true
  try {
    const res = await getOrderList({
      keyword: searchKeyword.value,
      status: filterStatus.value,
      page: page.value,
      size: 10
    })
    tableData.value = res.data || []
    total.value = res.total || 0
  } catch (e) {
    console.error('加载订单列表失败:', e)
  } finally {
    loading.value = false
  }
}

function viewDetail(id) { router.push(`/order/${id}`) }

onMounted(loadData)
</script>
