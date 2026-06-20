<template>
  <div class="settings">
    <div class="page-header"><h2>系统设置</h2></div>
    <el-card>
      <el-form :model="form" label-width="140px" v-loading="loading">
        <el-divider content-position="left">基本设置</el-divider>
        <el-form-item label="平台名称"><el-input v-model="form.siteName" style="width: 300px" /></el-form-item>
        <el-form-item label="客服电话"><el-input v-model="form.servicePhone" style="width: 300px" /></el-form-item>
        <el-form-item label="平台公告"><el-input v-model="form.announcement" type="textarea" :rows="3" style="width: 500px" /></el-form-item>

        <el-divider content-position="left">订单设置</el-divider>
        <el-form-item label="自动确认收货">
          <el-input-number v-model="form.autoConfirmDays" :min="1" :max="30" />
          <span style="margin-left: 8px">天</span>
        </el-form-item>
        <el-form-item label="争议处理时限">
          <el-input-number v-model="form.disputeDays" :min="1" :max="30" />
          <span style="margin-left: 8px">天</span>
        </el-form-item>

        <el-divider content-position="left">通知设置</el-divider>
        <el-form-item label="新订单通知"><el-switch v-model="form.orderNotify" /></el-form-item>
        <el-form-item label="争议提醒"><el-switch v-model="form.disputeNotify" /></el-form-item>

        <el-form-item><el-button type="primary" @click="handleSave" :loading="saving">保存设置</el-button></el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getSettings, saveSettings } from '@/api/settings'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const saving = ref(false)
const form = reactive({
  siteName: '',
  servicePhone: '',
  announcement: '',
  autoConfirmDays: 7,
  disputeDays: 7,
  orderNotify: true,
  disputeNotify: true,
})

async function loadSettings() {
  loading.value = true
  try {
    const res = await getSettings()
    if (res.data) Object.assign(form, res.data)
  } catch (e) { console.error('加载设置失败:', e) }
  finally { loading.value = false }
}

async function handleSave() {
  saving.value = true
  try {
    await saveSettings({ ...form })
    ElMessage.success('设置已保存')
  } catch (e) { ElMessage.error('保存设置失败') }
  finally { saving.value = false }
}

onMounted(loadSettings)
</script>
