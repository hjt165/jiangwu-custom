<template>
  <div class="content-image">
    <div class="page-header">
      <h2>图片审核</h2>
    </div>

    <div class="page-card">
      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="userName" label="上传用户" width="120" />
        <el-table-column prop="imageUrl" label="图片" width="120">
          <template #default="{ row }">
            <el-image :src="row.imageUrl" style="width: 60px; height: 60px" fit="cover" />
          </template>
        </el-table-column>
        <el-table-column prop="description" label="描述" />
        <el-table-column prop="createdAt" label="上传时间" width="180" />
        <el-table-column label="操作" fixed="right" width="200">
          <template #default="{ row }">
            <el-button type="success" link size="small" @click="handleAudit(row.id, 'pass')">通过</el-button>
            <el-button type="danger" link size="small" @click="handleAudit(row.id, 'reject')">拒绝</el-button>
            <el-button type="primary" link size="small">查看</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const loading = ref(false)
const tableData = ref([])

function loadData() {
  loading.value = true
  setTimeout(() => {
    tableData.value = [
      { id: 1, userName: '用户A', imageUrl: '', description: '参考图1', createdAt: '2026-06-14' },
    ]
    loading.value = false
  }, 500)
}

function handleAudit(id, action) {
  tableData.value = tableData.value.filter(item => item.id !== id)
}

onMounted(loadData)
</script>
