<template>
  <div class="dispute">
    <div class="page-header">
      <h2>争议仲裁</h2>
    </div>

    <div class="page-card">
      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="orderNo" label="订单号" width="200" />
        <el-table-column prop="userName" label="用户" width="120" />
        <el-table-column prop="artisanName" label="手作人" width="120" />
        <el-table-column prop="reason" label="争议原因" />
        <el-table-column prop="createdAt" label="提交时间" width="180" />
        <el-table-column label="操作" fixed="right" width="180">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="handleResolve(row)">仲裁</el-button>
            <el-button type="success" link size="small" @click="handleQuickResolve(row, 'user')">支持用户</el-button>
            <el-button type="warning" link size="small" @click="handleQuickResolve(row, 'artisan')">支持手作人</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <el-dialog v-model="dialogVisible" title="仲裁处理" width="500px">
      <el-form label-width="80px">
        <el-form-item label="裁决结果">
          <el-radio-group v-model="result">
            <el-radio value="user">支持用户</el-radio>
            <el-radio value="artisan">支持手作人</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="裁决说明">
          <el-input v-model="remark" type="textarea" :rows="3" placeholder="请输入裁决说明" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitResolve">确认</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getDisputeList, resolveDispute } from '@/api/order'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const tableData = ref([])
const dialogVisible = ref(false)
const result = ref('user')
const remark = ref('')
const currentOrderId = ref(null)

async function loadData() {
  loading.value = true
  try {
    const res = await getDisputeList({ page: 1, size: 10 })
    tableData.value = res.data || []
  } catch (e) {
    console.error('加载争议订单失败:', e)
  } finally {
    loading.value = false
  }
}

function handleResolve(row) {
  currentOrderId.value = row.id
  dialogVisible.value = true
}

async function submitResolve() {
  try {
    await resolveDispute(currentOrderId.value, {
      resolution: result.value,
      remark: remark.value
    })
    dialogVisible.value = false
    ElMessage.success('仲裁完成')
    loadData()
  } catch (e) {
    ElMessage.error('仲裁操作失败')
  }
}

async function handleQuickResolve(row, side) {
  const label = side === 'user' ? '支持用户' : '支持手作人'
  try {
    await resolveDispute(row.id, {
      resolution: side,
      remark: `管理员${label}`
    })
    ElMessage.success('仲裁完成')
    loadData()
  } catch (e) {
    ElMessage.error('仲裁操作失败')
  }
}

onMounted(loadData)
</script>
