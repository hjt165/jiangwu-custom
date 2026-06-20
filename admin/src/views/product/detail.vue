<template>
  <div class="product-detail" v-loading="loading">
    <div class="page-header">
      <h2>作品详情</h2>
      <el-button @click="$router.back()">返回</el-button>
    </div>
    <el-row :gutter="20">
      <el-col :span="16">
        <el-card>
          <template #header>作品信息</template>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="作品ID">{{ product.id }}</el-descriptions-item>
            <el-descriptions-item label="作品标题">{{ product.title }}</el-descriptions-item>
            <el-descriptions-item label="分类">{{ product.category }}</el-descriptions-item>
            <el-descriptions-item label="价格">¥{{ product.price }}</el-descriptions-item>
            <el-descriptions-item label="原价">
              <span v-if="product.originalPrice">¥{{ product.originalPrice }}</span>
              <span v-else>-</span>
            </el-descriptions-item>
            <el-descriptions-item label="评分">{{ product.rating || '-' }}</el-descriptions-item>
            <el-descriptions-item label="浏览量">{{ product.viewCount || 0 }}</el-descriptions-item>
            <el-descriptions-item label="收藏量">{{ product.likeCount || 0 }}</el-descriptions-item>
            <el-descriptions-item label="下单量">{{ product.orderCount || 0 }}</el-descriptions-item>
            <el-descriptions-item label="推荐">
              <el-tag :type="product.isFeatured ? 'success' : 'info'">
                {{ product.isFeatured ? '是' : '否' }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="审核状态">
              <el-tag :type="reviewStatusType">{{ reviewStatusLabel }}</el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="上架状态">
              <el-tag :type="product.isAvailable ? 'success' : 'danger'">
                {{ product.isAvailable ? '上架' : '下架' }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="创建时间" :span="2">{{ product.createdAt }}</el-descriptions-item>
            <el-descriptions-item label="作品描述" :span="2">{{ product.description || '暂无描述' }}</el-descriptions-item>
          </el-descriptions>
        </el-card>
        <el-card style="margin-top: 20px" v-if="product.tags && product.tags.length">
          <template #header>标签</template>
          <el-tag v-for="tag in product.tags" :key="tag" style="margin-right: 8px">{{ tag }}</el-tag>
        </el-card>
        <el-card style="margin-top: 20px" v-if="product.materials && product.materials.length">
          <template #header>材质</template>
          <el-tag v-for="m in product.materials" :key="m" type="info" style="margin-right: 8px">{{ m }}</el-tag>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card>
          <template #header>封面图</template>
          <el-image v-if="product.coverImage" :src="product.coverImage" fit="contain" style="width: 100%; height: 300px" />
          <el-empty v-else description="暂无封面图" />
        </el-card>
        <el-card style="margin-top: 20px">
          <template #header>操作</template>
          <el-space direction="vertical" fill style="width: 100%">
            <el-button type="warning" block @click="$router.back()">返回列表</el-button>
            <el-button v-if="product.reviewStatus === 0" type="success" block @click="handleAudit('pass')">审核通过</el-button>
            <el-button v-if="product.reviewStatus === 0" type="danger" block @click="handleAudit('reject')">审核拒绝</el-button>
          </el-space>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { getProductDetail, auditProduct } from '@/api/product'
import { ElMessage, ElMessageBox } from 'element-plus'

const route = useRoute()
const product = ref({})
const loading = ref(false)

const reviewStatusMap = { 0: '待审核', 1: '已通过', 2: '已拒绝' }
const reviewTypeMap = { 0: 'warning', 1: 'success', 2: 'danger' }
const reviewStatusLabel = computed(() => reviewStatusMap[product.value.reviewStatus] || '未知')
const reviewStatusType = computed(() => reviewTypeMap[product.value.reviewStatus] || 'info')

async function loadProduct() {
  loading.value = true
  try {
    const res = await getProductDetail(route.params.id)
    product.value = res.data || {}
  } catch (e) { console.error('加载作品详情失败:', e) }
  finally { loading.value = false }
}

async function handleAudit(action) {
  const label = action === 'pass' ? '通过' : '拒绝'
  try {
    await ElMessageBox.confirm(`确定${label}该作品吗？`, '审核确认', {
      confirmButtonText: '确定', cancelButtonText: '取消', type: action === 'pass' ? 'success' : 'warning'
    })
    await auditProduct(route.params.id, { action })
    ElMessage.success(`作品已${label}`)
    loadProduct()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error('审核操作失败')
  }
}

onMounted(loadProduct)
</script>
