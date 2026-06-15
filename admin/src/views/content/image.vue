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
import { getImageReviewList, reviewImage } from '@/api/content'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const tableData = ref([])

async function loadData() {
  loading.value = true
  try {
    const res = await getImageReviewList({ page: 1, size: 10 })
    tableData.value = res.data || []
  } catch (e) {
    console.error('加载图片列表失败:', e)
  } finally {
    loading.value = false
  }
}

async function handleAudit(id, action) {
  try {
    await reviewImage(id, { action })
    tableData.value = tableData.value.filter(item => item.id !== id)
    ElMessage.success(action === 'pass' ? '审核通过' : '已拒绝')
  } catch (e) {
    ElMessage.error('审核操作失败')
  }
}

onMounted(loadData)
</script>
