<template>
  <div class="user-list">
    <div class="page-header">
      <h2>用户列表</h2>
    </div>

    <div class="page-card">
      <div class="search-bar">
        <el-input v-model="searchKeyword" placeholder="搜索手机号/昵称" clearable style="width: 240px" />
        <el-select v-model="filterRole" placeholder="用户角色" clearable style="width: 140px">
          <el-option label="普通用户" :value="0" />
          <el-option label="手作人" :value="1" />
          <el-option label="管理员" :value="2" />
        </el-select>
        <el-button type="primary" @click="handleSearch">搜索</el-button>
      </div>

      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="phone" label="手机号" width="140" />
        <el-table-column prop="nickname" label="昵称" width="140" />
        <el-table-column prop="role" label="角色" width="100">
          <template #default="{ row }">
            <el-tag :type="row.role === 2 ? 'danger' : row.role === 1 ? 'warning' : 'info'">
              {{ row.role === 2 ? '管理员' : row.role === 1 ? '手作人' : '用户' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="creditScore" label="信用分" width="100" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'">
              {{ row.status === 1 ? '正常' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="注册时间" width="180" />
        <el-table-column label="操作" fixed="right" width="150">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="viewDetail(row.id)">详情</el-button>
            <el-button :type="row.status === 1 ? 'danger' : 'success'" link size="small" @click="toggleStatus(row)">
              {{ row.status === 1 ? '禁用' : '启用' }}
            </el-button>
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
import { getUserList, updateUserStatus } from '@/api/user'
import { ElMessage } from 'element-plus'

const router = useRouter()
const loading = ref(false)
const tableData = ref([])
const searchKeyword = ref('')
const filterRole = ref('')
const page = ref(1)
const total = ref(0)

async function loadData() {
  loading.value = true
  try {
    const res = await getUserList({
      keyword: searchKeyword.value,
      page: page.value,
      size: 10
    })
    tableData.value = res.data || []
    total.value = res.total || 0
  } catch (e) {
    console.error('加载用户列表失败:', e)
  } finally {
    loading.value = false
  }
}

function handleSearch() {
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
