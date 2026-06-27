<template>
  <div class="content-comment">
    <div class="page-header">
      <h2>评论审核</h2>
    </div>

    <div class="page-card">
      <!-- 搜索栏 -->
      <div class="search-bar">
        <el-input
          v-model="searchKeyword"
          placeholder="搜索评论内容"
          clearable
          style="width: 200px"
          @keyup.enter="handleSearch"
        />
        <el-select v-model="searchStatus" placeholder="审核状态" clearable style="width: 120px; margin-left: 10px">
          <el-option label="待审核" :value="0" />
          <el-option label="已通过" :value="1" />
          <el-option label="已拒绝" :value="2" />
        </el-select>
        <el-select v-model="searchRating" placeholder="评分筛选" clearable style="width: 120px; margin-left: 10px">
          <el-option label="1星" :value="1" />
          <el-option label="2星" :value="2" />
          <el-option label="3星" :value="3" />
          <el-option label="4星" :value="4" />
          <el-option label="5星" :value="5" />
        </el-select>
        <el-button type="primary" style="margin-left: 10px" @click="handleSearch">搜索</el-button>
        <el-button @click="handleReset">重置</el-button>
        <el-button
          type="success"
          :disabled="selectedIds.length === 0"
          @click="handleBatchAudit('pass')"
        >批量通过</el-button>
        <el-button
          type="danger"
          :disabled="selectedIds.length === 0"
          @click="handleBatchAudit('reject')"
        >批量拒绝</el-button>
      </div>

      <!-- 数据表格 -->
      <el-table
        :data="tableData"
        stripe
        v-loading="loading"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55" />
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="userName" label="用户" width="120" />
        <el-table-column prop="content" label="评论内容" show-overflow-tooltip />
        <el-table-column prop="rating" label="评分" width="100">
          <template #default="{ row }">
            <el-rate v-model="row.rating" disabled />
          </template>
        </el-table-column>
        <el-table-column prop="reviewStatus" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.reviewStatus)">
              {{ getStatusText(row.reviewStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="评论时间" width="180" />
        <el-table-column label="操作" fixed="right" width="200">
          <template #default="{ row }">
            <el-button
              v-if="row.reviewStatus === 0"
              type="success"
              link
              size="small"
              @click="handleAudit(row.id, 'pass')"
            >通过</el-button>
            <el-button
              v-if="row.reviewStatus === 0"
              type="danger"
              link
              size="small"
              @click="handleAudit(row.id, 'reject')"
            >拒绝</el-button>
            <el-button type="primary" link size="small" @click="handleView(row)">查看</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="loadData"
          @current-change="loadData"
        />
      </div>
    </div>

    <!-- 拒绝原因对话框 -->
    <el-dialog v-model="rejectDialogVisible" title="拒绝原因" width="400px">
      <el-input
        v-model="rejectReason"
        type="textarea"
        :rows="3"
        placeholder="请输入拒绝原因"
      />
      <template #footer>
        <el-button @click="rejectDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmReject">确认</el-button>
      </template>
    </el-dialog>

    <!-- 评论详情对话框 -->
    <el-dialog v-model="detailDialogVisible" title="评论详情" width="500px">
      <div v-if="currentComment">
        <p><strong>用户：</strong>{{ currentComment.userName }}</p>
        <p><strong>评分：</strong><el-rate v-model="currentComment.rating" disabled /></p>
        <p><strong>内容：</strong>{{ currentComment.content }}</p>
        <p v-if="currentComment.images && currentComment.images.length">
          <strong>图片：</strong>
        </p>
        <div v-if="currentComment.images && currentComment.images.length" class="comment-images">
          <el-image
            v-for="(img, index) in currentComment.images"
            :key="index"
            :src="img"
            style="width: 100px; height: 100px; margin-right: 8px"
            fit="cover"
            :preview-src-list="currentComment.images"
          />
        </div>
        <p v-if="currentComment.tags && currentComment.tags.length">
          <strong>标签：</strong>
          <el-tag v-for="tag in currentComment.tags" :key="tag" style="margin-right: 4px">{{ tag }}</el-tag>
        </p>
        <p><strong>评论时间：</strong>{{ currentComment.createdAt }}</p>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getCommentReviewList, reviewComment, batchReviewComments } from '@/api/content'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const tableData = ref([])
const searchKeyword = ref('')
const searchStatus = ref(0)
const searchRating = ref(null)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const selectedIds = ref([])

// 拒绝相关
const rejectDialogVisible = ref(false)
const rejectReason = ref('')
const currentRejectId = ref(null)
const isBatchReject = ref(false)

// 详情相关
const detailDialogVisible = ref(false)
const currentComment = ref(null)

async function loadData() {
  loading.value = true
  try {
    const res = await getCommentReviewList({
      keyword: searchKeyword.value,
      status: searchStatus.value,
      minRating: searchRating.value,
      maxRating: searchRating.value,
      page: currentPage.value - 1,
      size: pageSize.value
    })
    tableData.value = res.data?.data || []
    total.value = res.data?.total || 0
  } catch (e) {
    console.error('加载评论列表失败:', e)
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  currentPage.value = 1
  loadData()
}

function handleReset() {
  searchKeyword.value = ''
  searchStatus.value = 0
  searchRating.value = null
  currentPage.value = 1
  loadData()
}

function handleSelectionChange(selection) {
  selectedIds.value = selection.map(item => item.id)
}

async function handleAudit(id, action) {
  if (action === 'reject') {
    currentRejectId.value = id
    isBatchReject.value = false
    rejectReason.value = ''
    rejectDialogVisible.value = true
    return
  }

  try {
    await ElMessageBox.confirm('确认通过该评论审核？', '确认操作', {
      confirmButtonText: '确认',
      cancelButtonText: '取消',
      type: 'success'
    })
    await reviewComment(id, { action })
    ElMessage.success('审核通过')
    loadData()
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error('审核操作失败')
    }
  }
}

async function handleBatchAudit(action) {
  if (action === 'reject') {
    isBatchReject.value = true
    rejectReason.value = ''
    rejectDialogVisible.value = true
    return
  }

  try {
    await ElMessageBox.confirm(`确认通过选中的${selectedIds.value.length}条评论？`, '批量审核', {
      confirmButtonText: '确认',
      cancelButtonText: '取消',
      type: 'success'
    })
    await batchReviewComments({ ids: selectedIds.value, action })
    ElMessage.success('批量审核通过')
    selectedIds.value = []
    loadData()
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error('批量审核失败')
    }
  }
}

async function confirmReject() {
  try {
    if (isBatchReject.value) {
      await batchReviewComments({
        ids: selectedIds.value,
        action: 'reject',
        remark: rejectReason.value
      })
      ElMessage.success('批量拒绝成功')
      selectedIds.value = []
    } else {
      await reviewComment(currentRejectId.value, {
        action: 'reject',
        remark: rejectReason.value
      })
      ElMessage.success('拒绝成功')
    }
    rejectDialogVisible.value = false
    loadData()
  } catch (e) {
    ElMessage.error('操作失败')
  }
}

function handleView(row) {
  currentComment.value = row
  detailDialogVisible.value = true
}

function getStatusType(status) {
  const types = { 0: 'warning', 1: 'success', 2: 'danger' }
  return types[status] || 'info'
}

function getStatusText(status) {
  const texts = { 0: '待审核', 1: '已通过', 2: '已拒绝' }
  return texts[status] || '未知'
}

onMounted(loadData)
</script>

<style scoped>
.search-bar {
  display: flex;
  align-items: center;
  margin-bottom: 16px;
}
.pagination-wrapper {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
}
.comment-images {
  display: flex;
  flex-wrap: wrap;
  margin-top: 8px;
}
</style>