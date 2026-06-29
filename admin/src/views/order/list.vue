<template>
  <div class="page-container">
    <div class="page-head">
      <div>
        <h1>订单管理</h1>
        <p class="page-desc">管理平台所有订单</p>
      </div>
    </div>

    <div class="search-panel">
      <el-input
        v-model="searchKeyword"
        placeholder="搜索订单号"
        clearable
        class="search-input"
        @keyup.enter="handleSearch"
      />
      <el-select v-model="filterStatus" placeholder="订单状态" clearable class="search-select">
        <el-option label="待付款" value="pending_payment" />
        <el-option label="已付款" value="paid" />
        <el-option label="制作中" value="producing" />
        <el-option label="已完成" value="completed" />
        <el-option label="已取消" value="cancelled" />
      </el-select>
      <el-button @click="handleSearch">搜索</el-button>
      <el-button @click="resetSearch">重置</el-button>
    </div>

    <div class="table-panel">
      <el-table :data="tableData" v-loading="loading" class="main-table">
        <el-table-column prop="orderNo" label="订单号" width="200" />
        <el-table-column label="用户" width="100">
          <template #default="{ row }">#{{ row.userId }}</template>
        </el-table-column>
        <el-table-column label="手作人" width="110">
          <template #default="{ row }">{{ row.artisanId ? '#' + row.artisanId : '-' }}</template>
        </el-table-column>
        <el-table-column label="金额" width="95" class-name="mono">
          <template #default="{ row }">¥{{ row.totalAmount }}</template>
        </el-table-column>
        <el-table-column label="状态" width="110">
          <template #default="{ row }">
            <OrderStatus :status="row.status" />
          </template>
        </el-table-column>
        <el-table-column label="下单时间" width="170">
          <template #default="{ row }">{{ formatDate(row.createdAt) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="80" fixed="right">
          <template #default="{ row }">
            <el-link type="primary" @click="viewDetail(row.id)">详情</el-link>
          </template>
        </el-table-column>
      </el-table>

      <div v-if="!loading && !tableData.length" class="empty-state">暂无订单</div>

      <div class="pagination-wrap" v-if="total > 0">
        <el-pagination
          v-model:current-page="page"
          :page-size="pageSize"
          :total="total"
          layout="total, prev, pager, next"
          @current-change="loadData"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getOrderList } from '@/api/order'
import OrderStatus from '@/components/business/OrderStatus.vue'

const router = useRouter()
const loading = ref(false)
const tableData = ref([])
const searchKeyword = ref('')
const filterStatus = ref('')
const page = ref(1)
const total = ref(0)
const pageSize = 10

function formatDate(dateStr) {
  if (!dateStr) return '-'
  const d = new Date(dateStr)
  const pad = n => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`
}

async function loadData() {
  loading.value = true
  try {
    const res = await getOrderList({
      keyword: searchKeyword.value,
      status: filterStatus.value,
      page: page.value - 1,
      size: pageSize
    })
    tableData.value = res.data?.data || []
    total.value = res.data?.total || 0
  } catch (e) {
    console.error('获取订单列表失败:', e)
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  page.value = 1
  loadData()
}

function resetSearch() {
  searchKeyword.value = ''
  filterStatus.value = ''
  page.value = 1
  loadData()
}

function viewDetail(id) {
  router.push(`/order/${id}`)
}

onMounted(loadData)
</script>

<style lang="scss" scoped>
.page-container {
  padding: 28px 32px;
}

.page-head {
  margin-bottom: 24px;

  h1 {
    font-size: 20px;
    font-weight: 600;
    color: #2C3E50;
    margin: 0 0 4px;
  }

  .page-desc {
    font-size: 13px;
    color: #909399;
    margin: 0;
  }
}

.search-panel {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
  flex-wrap: wrap;
  align-items: center;

  .search-input {
    width: 200px;
  }

  .search-select {
    width: 140px;
  }
}

.table-panel {
  background: #fff;
  border: 1px solid #F0F0F0;
  border-radius: 8px;
  overflow: hidden;
}

.main-table {
  :deep(.el-table__header) th {
    background: #FAFAF9;
    color: #606266;
    font-weight: 500;
    font-size: 13px;
    border-bottom: 1px solid #F0F0F0;
  }

  :deep(.el-table__row) td {
    font-size: 13px;
    border-bottom: 1px solid #F5F5F5;
  }

  :deep(.el-table__body tr:last-child td) {
    border-bottom: none;
  }

  :deep(.mono) {
    font-family: 'SF Mono', 'Menlo', monospace;
    color: #2C3E50;
  }
}

.empty-state {
  text-align: center;
  padding: 60px 0;
  color: #C0C4CC;
  font-size: 14px;
}

.pagination-wrap {
  padding: 16px 20px;
  border-top: 1px solid #F0F0F0;
  display: flex;
  justify-content: flex-end;
}
</style>
