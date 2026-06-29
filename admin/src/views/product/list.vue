<template>
  <div class="page-container">
    <div class="page-head">
      <div>
        <h1>商品管理</h1>
        <p class="page-desc">管理平台所有上架商品</p>
      </div>
    </div>

    <div class="search-panel">
      <el-input
        v-model="searchKeyword"
        placeholder="搜索商品名称"
        clearable
        class="search-input"
        @keyup.enter="handleSearch"
      />
      <el-button @click="handleSearch">搜索</el-button>
      <el-button @click="resetSearch">重置</el-button>
    </div>

    <div class="table-panel">
      <el-table :data="tableData" v-loading="loading" class="main-table">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="title" label="商品名称" min-width="180" />
        <el-table-column label="分类" width="100">
          <template #default="{ row }">{{ row.category || '-' }}</template>
        </el-table-column>
        <el-table-column label="手作人" width="110">
          <template #default="{ row }">{{ row.craftParams?.artisanName || '-' }}</template>
        </el-table-column>
        <el-table-column label="价格" width="90" class-name="mono">
          <template #default="{ row }">¥{{ row.price }}</template>
        </el-table-column>
        <el-table-column label="审核状态" width="100">
          <template #default="{ row }">
            <span class="review-tag" :class="'review-' + reviewClass(row.reviewStatus)">
              {{ reviewName(row.reviewStatus) }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="发布时间" width="170">
          <template #default="{ row }">{{ formatDate(row.createdAt) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-link type="primary" @click="$router.push('/product/' + row.id)">查看</el-link>
            <el-divider direction="vertical" />
            <template v-if="row.reviewStatus === 0">
              <el-link type="success" @click="handleAudit(row, 'pass')" :loading="auditLoading[row.id]">通过</el-link>
              <el-divider direction="vertical" />
              <el-link type="danger" @click="handleAudit(row, 'reject')" :loading="auditLoading[row.id]">拒绝</el-link>
            </template>
          </template>
        </el-table-column>
      </el-table>

      <div v-if="!loading && !tableData.length" class="empty-state">暂无商品</div>

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
import { ref, reactive, onMounted } from 'vue'
import { getProductList, auditProduct } from '@/api/product'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const tableData = ref([])
const searchKeyword = ref('')
const page = ref(1)
const total = ref(0)
const pageSize = 10
const auditLoading = reactive({})

function reviewName(status) {
  const map = { 0: '待审核', 1: '已通过', 2: '已拒绝' }
  return map[status] || '未知'
}

function reviewClass(status) {
  const map = { 0: 'pending', 1: 'passed', 2: 'rejected' }
  return map[status] || 'unknown'
}

function formatDate(dateStr) {
  if (!dateStr) return '-'
  const d = new Date(dateStr)
  const pad = n => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`
}

async function loadData() {
  loading.value = true
  try {
    const res = await getProductList({
      keyword: searchKeyword.value,
      page: page.value - 1,
      size: pageSize
    })
    tableData.value = res.data?.data || []
    total.value = res.data?.total || 0
  } catch (e) {
    console.error('获取商品列表失败:', e)
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
  page.value = 1
  loadData()
}

async function handleAudit(row, action) {
  const label = action === 'pass' ? '通过' : '拒绝'
  try {
    await ElMessageBox.confirm(`确认${label}此商品？`, '确认', {
      confirmButtonText: '确认',
      cancelButtonText: '取消',
      type: action === 'pass' ? 'success' : 'warning'
    })
    auditLoading[row.id] = true
    await auditProduct(row.id, { action })
    ElMessage.success(`商品已${label}`)
    loadData()
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error('审核失败')
    }
  } finally {
    auditLoading[row.id] = false
  }
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
  align-items: center;

  .search-input {
    width: 220px;
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

.review-tag {
  display: inline-block;
  padding: 2px 10px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;

  &.review-pending {
    background: #FEF0E6;
    color: #E67E22;
  }

  &.review-passed {
    background: #E8FAE8;
    color: #27AE60;
  }

  &.review-rejected {
    background: #FDE8E8;
    color: #E74C3C;
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
