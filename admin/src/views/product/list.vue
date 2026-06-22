<template>
  <div class="product-list">
    <div class="page-header">
      <h2>作品管理</h2>
    </div>

    <div class="page-card">
      <div class="search-bar">
        <el-input v-model="searchKeyword" placeholder="搜索作品名称" clearable style="width: 240px" />
        <el-button type="primary" @click="handleSearch">搜索</el-button>
      </div>

      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="作品名称" min-width="150" />
        <el-table-column prop="category" label="分类" width="100" />
        <el-table-column prop="artisanName" label="手作人" width="120" />
        <el-table-column prop="price" label="价格" width="100">
          <template #default="{ row }">¥{{ row.price }}</template>
        </el-table-column>
        <el-table-column prop="reviewStatus" label="审核状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.reviewStatus === 1 ? 'success' : row.reviewStatus === 2 ? 'danger' : 'warning'">
              {{ row.reviewStatus === 1 ? '已通过' : row.reviewStatus === 2 ? '已拒绝' : '待审核' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="创建时间" width="180" />
        <el-table-column label="操作" fixed="right" width="150">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="$router.push('/product/' + row.id)">详情</el-button>
            <el-button v-if="row.reviewStatus === 0" type="success" link size="small" :loading="auditLoading[row.id]" :disabled="auditLoading[row.id]" @click="handleAudit(row, 'pass')">通过</el-button>
            <el-button v-if="row.reviewStatus === 0" type="danger" link size="small" :loading="auditLoading[row.id]" :disabled="auditLoading[row.id]" @click="handleAudit(row, 'reject')">拒绝</el-button>
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
import { ref, reactive, onMounted } from 'vue'
import { getProductList, auditProduct } from '@/api/product'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const tableData = ref([])
const searchKeyword = ref('')
const page = ref(1)
const total = ref(0)
const auditLoading = reactive({})

async function loadData() {
  loading.value = true
  try {
    const res = await getProductList({
      keyword: searchKeyword.value,
      page: page.value,
      size: 10
    })
    tableData.value = res.data || []
    total.value = res.total || 0
  } catch (e) {
    console.error('加载作品列表失败:', e)
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  page.value = 1
  loadData()
}

async function handleAudit(row, action) {
  const label = action === 'pass' ? '通过' : '拒绝'
  try {
    await ElMessageBox.confirm(`确定${label}该作品吗？`, '审核确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: action === 'pass' ? 'success' : 'warning'
    })
    auditLoading[row.id] = true
    await auditProduct(row.id, { action })
    ElMessage.success(`作品已${label}`)
    loadData()
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error('审核操作失败')
    }
  } finally {
    auditLoading[row.id] = false
  }
}

onMounted(loadData)
</script>
