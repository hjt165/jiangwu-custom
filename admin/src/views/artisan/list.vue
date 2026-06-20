<template>
  <div class="artisan-list">
    <div class="page-header">
      <h2>手作人管理</h2>
    </div>

    <div class="page-card">
      <div class="search-bar">
        <el-input v-model="searchKeyword" placeholder="搜索手作人名称" clearable style="width: 240px" />
        <el-button type="primary" @click="handleSearch">搜索</el-button>
      </div>

      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="手作人名称" min-width="150" />
        <el-table-column prop="specialty" label="擅长领域" width="150" />
        <el-table-column prop="yearsOfExp" label="从业年限" width="100" />
        <el-table-column prop="rating" label="评分" width="80">
          <template #default="{ row }">{{ row.rating || '-' }}</template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'warning'">
              {{ row.status === 1 ? '已认证' : '待审核' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" fixed="right" width="150">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="$router.push('/artisan/' + row.id)">详情</el-button>
            <el-button v-if="row.status !== 1" type="success" link size="small" @click="handleAudit(row, 'pass')">认证</el-button>
            <el-button v-if="row.status !== 1" type="danger" link size="small" @click="handleAudit(row, 'reject')">拒绝</el-button>
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
import { getArtisanList, auditArtisan } from '@/api/artisan'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const tableData = ref([])
const searchKeyword = ref('')
const page = ref(1)
const total = ref(0)

async function loadData() {
  loading.value = true
  try {
    const res = await getArtisanList({
      keyword: searchKeyword.value,
      page: page.value,
      size: 10
    })
    tableData.value = res.data || []
    total.value = res.total || 0
  } catch (e) {
    console.error('加载手作人列表失败:', e)
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  page.value = 1
  loadData()
}

async function handleAudit(row, action) {
  const label = action === 'pass' ? '认证通过' : '拒绝'
  try {
    await ElMessageBox.confirm(`确定${label}该手作人吗？`, '审核确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: action === 'pass' ? 'success' : 'warning'
    })
    await auditArtisan(row.id, { action })
    ElMessage.success(`手作人已${label}`)
    loadData()
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error('审核操作失败')
    }
  }
}

onMounted(loadData)
</script>
