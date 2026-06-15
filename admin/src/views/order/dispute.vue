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
            <el-button type="success" link size="small">支持用户</el-button>
            <el-button type="warning" link size="small">支持手作人</el-button>
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

const loading = ref(false)
const tableData = ref([])
const dialogVisible = ref(false)
const result = ref('user')
const remark = ref('')

function loadData() {
  loading.value = true
  setTimeout(() => {
    tableData.value = [
      { id: 1, orderNo: 'JW20260614001', userName: '用户A', artisanName: '手作达人', reason: '与描述不符', createdAt: '2026-06-14' },
    ]
    loading.value = false
  }, 500)
}

function handleResolve(row) { dialogVisible.value = true }
function submitResolve() { dialogVisible.value = false }

onMounted(loadData)
</script>
