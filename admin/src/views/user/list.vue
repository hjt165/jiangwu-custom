<template>
  <div class="page-container">
    <div class="page-head">
      <div>
        <h1>用户管理</h1>
        <p class="page-desc">管理平台注册用户</p>
      </div>
    </div>

    <!-- 搜索栏 -->
    <div class="search-panel">
      <el-input
        v-model="searchKeyword"
        placeholder="搜索手机号/昵称"
        clearable
        class="search-input"
        @keyup.enter="handleSearch"
      />
      <el-select
        v-model="filterRole"
        placeholder="用户角色"
        clearable
        class="search-select"
      >
        <el-option label="普通用户" :value="0" />
        <el-option label="手作人" :value="1" />
        <el-option label="管理员" :value="2" />
      </el-select>
      <el-button @click="handleSearch">搜索</el-button>
      <el-button @click="resetSearch">重置</el-button>
    </div>

    <!-- 表格 -->
    <div class="table-panel">
      <el-table :data="tableData" v-loading="loading" class="main-table">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="phone" label="手机号" width="140" />
        <el-table-column prop="nickname" label="昵称" min-width="140" />
        <el-table-column label="角色" width="100">
          <template #default="{ row }">
            <span class="role-tag" :class="'role-' + roleClass(row.role)">
              {{ roleName(row.role) }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="信用分" width="90" class-name="mono">
          <template #default="{ row }">
            {{ row.creditScore }}
          </template>
        </el-table-column>
        <el-table-column label="状态" width="90">
          <template #default="{ row }">
            <span class="status-dot" :class="row.status === 1 ? 'active' : 'disabled'"></span>
            <span class="status-text">{{ row.status === 1 ? '正常' : '禁用' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="注册时间" width="170">
          <template #default="{ row }">
            {{ formatDate(row.createdAt) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="140" fixed="right">
          <template #default="{ row }">
            <el-link type="primary" @click="viewDetail(row.id)">详情</el-link>
            <el-divider direction="vertical" />
            <el-link
              :type="row.status === 1 ? 'danger' : 'success'"
              @click="toggleStatus(row)"
            >
              {{ row.status === 1 ? '禁用' : '启用' }}
            </el-link>
          </template>
        </el-table-column>
      </el-table>

      <div v-if="!loading && !tableData.length" class="empty-state">
        <span>暂无数据</span>
      </div>

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
import { getUserList, updateUserStatus } from '@/api/user'
import { ElMessage } from 'element-plus'

const router = useRouter()
const loading = ref(false)
const tableData = ref([])
const searchKeyword = ref('')
const filterRole = ref('')
const page = ref(1)
const total = ref(0)
const pageSize = 10

function roleName(role) {
  const map = { 0: '普通用户', 1: '手作人', 2: '管理员' }
  return map[role] || '未知'
}

function roleClass(role) {
  const map = { 0: 'default', 1: 'artisan', 2: 'admin' }
  return map[role] || 'default'
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
    const res = await getUserList({
      keyword: searchKeyword.value,
      page: page.value - 1,
      size: pageSize
    })
    tableData.value = res.data?.data || []
    total.value = res.data?.total || 0
  } catch (e) {
    console.error('获取用户列表失败:', e)
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
  filterRole.value = ''
  page.value = 1
  loadData()
}

function viewDetail(id) {
  router.push(`/user/${id}`)
}

async function toggleStatus(row) {
  try {
    const newStatus = row.status === 1 ? 0 : 1
    await updateUserStatus(row.id, newStatus)
    row.status = newStatus
    ElMessage.success('状态更新成功')
  } catch (e) {
    ElMessage.error('状态更新失败')
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

/* 搜索面板 */
.search-panel {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
  flex-wrap: wrap;
  align-items: center;

  .search-input {
    width: 220px;
  }

  .search-select {
    width: 140px;
  }
}

/* 表格面板 */
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
    padding: 0;

    &:last-child {
      padding-right: 16px;
    }
  }

  :deep(.el-table__body tr:last-child td) {
    border-bottom: none;
  }

  :deep(.el-table__body tr:hover > td) {
    background: #FAFAF9;
  }

  :deep(.mono) {
    font-family: 'SF Mono', 'Menlo', monospace;
    font-size: 13px;
    color: #2C3E50;
  }
}

/* 角色标签 */
.role-tag {
  display: inline-block;
  padding: 2px 10px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;

  &.role-default {
    background: #F5F5F5;
    color: #606266;
  }

  &.role-artisan {
    background: #FEF0E6;
    color: #E67E22;
  }

  &.role-admin {
    background: #FDE8E8;
    color: #E74C3C;
  }
}

/* 状态点 */
.status-dot {
  display: inline-block;
  width: 6px;
  height: 6px;
  border-radius: 50%;
  margin-right: 6px;
  vertical-align: middle;

  &.active { background: #27AE60; }
  &.disabled { background: #DCDFE6; }
}

.status-text {
  font-size: 13px;
  color: #606266;
}

/* 空状态 */
.empty-state {
  text-align: center;
  padding: 60px 0;
  color: #C0C4CC;
  font-size: 14px;
}

/* 分页 */
.pagination-wrap {
  padding: 16px 20px;
  border-top: 1px solid #F0F0F0;
  display: flex;
  justify-content: flex-end;
}
</style>
