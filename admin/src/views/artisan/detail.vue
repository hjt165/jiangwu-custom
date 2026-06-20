<template>
  <div class="artisan-detail" v-loading="loading">
    <div class="page-header">
      <h2>手作人详情</h2>
      <el-button @click="$router.back()">返回</el-button>
    </div>
    <el-row :gutter="20">
      <el-col :span="16">
        <el-card>
          <template #header>基本信息</template>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="手作人ID">{{ artisan.id }}</el-descriptions-item>
            <el-descriptions-item label="名称">{{ artisan.name }}</el-descriptions-item>
            <el-descriptions-item label="擅长领域">{{ artisan.specialty || '-' }}</el-descriptions-item>
            <el-descriptions-item label="从业年限">{{ artisan.yearsOfExp || '-' }} 年</el-descriptions-item>
            <el-descriptions-item label="所在地">{{ artisan.location || '-' }}</el-descriptions-item>
            <el-descriptions-item label="评分">{{ artisan.rating || '-' }}</el-descriptions-item>
            <el-descriptions-item label="订单数">{{ artisan.orderCount || 0 }}</el-descriptions-item>
            <el-descriptions-item label="粉丝数">{{ artisan.fanCount || 0 }}</el-descriptions-item>
            <el-descriptions-item label="认证状态">
              <el-tag :type="statusType">{{ statusLabel }}</el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="申请时间">{{ artisan.appliedAt || '-' }}</el-descriptions-item>
            <el-descriptions-item label="通过时间">{{ artisan.approvedAt || '-' }}</el-descriptions-item>
            <el-descriptions-item label="创建时间">{{ artisan.createdAt }}</el-descriptions-item>
            <el-descriptions-item label="个人简介" :span="2">{{ artisan.bio || '暂无简介' }}</el-descriptions-item>
          </el-descriptions>
        </el-card>
        <el-card style="margin-top: 20px" v-if="artisan.certifications && artisan.certifications.length">
          <template #header>资质认证</template>
          <el-tag v-for="c in artisan.certifications" :key="c" type="info" style="margin-right: 8px">{{ c }}</el-tag>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card>
          <template #header>头像</template>
          <el-image v-if="artisan.avatar" :src="artisan.avatar" fit="contain" style="width: 100%; height: 300px" />
          <el-empty v-else description="暂无头像" />
        </el-card>
        <el-card style="margin-top: 20px">
          <template #header>操作</template>
          <el-space direction="vertical" fill style="width: 100%">
            <el-button type="warning" block @click="$router.back()">返回列表</el-button>
            <el-button v-if="artisan.status === 0" type="success" block @click="handleAudit('pass')">认证通过</el-button>
            <el-button v-if="artisan.status === 0" type="danger" block @click="handleAudit('reject')">拒绝认证</el-button>
          </el-space>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { getArtisanDetail, auditArtisan } from '@/api/artisan'
import { ElMessage, ElMessageBox } from 'element-plus'

const route = useRoute()
const artisan = ref({})
const loading = ref(false)

const statusMap = { 0: '待审核', 1: '已认证', 2: '已拒绝', 3: '已封禁' }
const typeMap = { 0: 'warning', 1: 'success', 2: 'danger', 3: 'info' }
const statusLabel = computed(() => statusMap[artisan.value.status] || '未知')
const statusType = computed(() => typeMap[artisan.value.status] || 'info')

async function loadArtisan() {
  loading.value = true
  try {
    const res = await getArtisanDetail(route.params.id)
    artisan.value = res.data || {}
  } catch (e) { console.error('加载手作人详情失败:', e) }
  finally { loading.value = false }
}

async function handleAudit(action) {
  const label = action === 'pass' ? '认证通过' : '拒绝认证'
  try {
    await ElMessageBox.confirm(`确定${label}该手作人吗？`, '审核确认', {
      confirmButtonText: '确定', cancelButtonText: '取消', type: action === 'pass' ? 'success' : 'warning'
    })
    await auditArtisan(route.params.id, { action })
    ElMessage.success(`手作人已${label}`)
    loadArtisan()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error('审核操作失败')
  }
}

onMounted(loadArtisan)
</script>
