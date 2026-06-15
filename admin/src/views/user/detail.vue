<template>
  <div class="user-detail">
    <div class="page-header">
      <h2>用户详情</h2>
      <el-button @click="$router.back()">返回</el-button>
    </div>

    <el-row :gutter="20">
      <el-col :span="8">
        <el-card>
          <template #header>基本信息</template>
          <el-descriptions :column="1" border>
            <el-descriptions-item label="ID">{{ user.id }}</el-descriptions-item>
            <el-descriptions-item label="手机号">{{ user.phone }}</el-descriptions-item>
            <el-descriptions-item label="昵称">{{ user.nickname }}</el-descriptions-item>
            <el-descriptions-item label="角色">
              <el-tag :type="user.role === 2 ? 'danger' : user.role === 1 ? 'warning' : 'info'">
                {{ user.role === 2 ? '管理员' : user.role === 1 ? '手作人' : '用户' }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="信用分">{{ user.creditScore }}</el-descriptions-item>
            <el-descriptions-item label="状态">
              <el-tag :type="user.status === 1 ? 'success' : 'danger'">
                {{ user.status === 1 ? '正常' : '禁用' }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="注册时间">{{ user.createdAt }}</el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-col>
      <el-col :span="16">
        <el-card>
          <template #header>操作</template>
          <el-form label-width="100px">
            <el-form-item label="信用分调整">
              <el-input-number v-model="creditScore" :min="0" :max="100" />
              <el-button type="primary" style="margin-left: 12px" @click="updateCredit">调整</el-button>
            </el-form-item>
            <el-form-item label="账号状态">
              <el-switch v-model="user.status" :active-value="1" :inactive-value="0" active-text="正常" inactive-text="禁用" />
            </el-form-item>
          </el-form>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const user = ref({})
const creditScore = ref(0)

onMounted(() => {
  user.value = {
    id: route.params.id,
    phone: '13800000001',
    nickname: '测试用户',
    role: 0,
    creditScore: 100,
    status: 1,
    createdAt: '2026-06-14',
  }
  creditScore.value = user.value.creditScore
})

function updateCredit() {
  user.value.creditScore = creditScore.value
}
</script>
