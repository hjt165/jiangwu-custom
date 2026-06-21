<template>
  <div class="login-container">
    <div class="login-bg-pattern"></div>
    <div class="login-card">
      <div class="login-header">
        <div class="brand-icon">
          <svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
            <rect x="4" y="4" width="40" height="40" rx="8" fill="#2C3E50"/>
            <path d="M14 34V18l10 8-10 8z" fill="#E74C3C"/>
            <path d="M24 18v16l10-8-10-8z" fill="#F5F5F0" opacity="0.8"/>
          </svg>
        </div>
        <h1>匠物定制</h1>
        <p class="subtitle">管理后台</p>
        <p class="desc">小众手作艺术品定制平台</p>
      </div>

      <el-form ref="formRef" :model="form" :rules="rules" class="login-form">
        <el-form-item prop="phone">
          <el-input v-model="form.phone" placeholder="请输入手机号" prefix-icon="User" size="large" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="form.password" type="password" placeholder="请输入密码" prefix-icon="Lock" size="large" show-password />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="large" :loading="loading" class="login-btn" @click="handleLogin">
            登 录
          </el-button>
        </el-form-item>
      </el-form>

      <div class="login-footer">
        <span>测试账号: 13800000000 / admin123</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useUserStore } from '@/store/user'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const formRef = ref(null)
const loading = ref(false)

const form = reactive({
  phone: '',
  password: '',
})

const rules = {
  phone: [{ required: true, message: '请输入手机号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
}

async function handleLogin() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return

  loading.value = true
  try {
    await userStore.login(form)
    ElMessage.success('登录成功')
  } catch (err) {
    ElMessage.error(err.message || '登录失败')
  } finally {
    loading.value = false
  }
}
</script>

<style lang="scss" scoped>
.login-container {
  width: 100%;
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(160deg, #1a252f 0%, #2C3E50 40%, #34495E 100%);
  position: relative;
  overflow: hidden;
}

.login-bg-pattern {
  position: absolute;
  inset: 0;
  opacity: 0.04;
  background-image:
    radial-gradient(circle at 20% 80%, #E74C3C 1px, transparent 1px),
    radial-gradient(circle at 80% 20%, #E74C3C 1px, transparent 1px),
    radial-gradient(circle at 50% 50%, #E74C3C 0.5px, transparent 0.5px);
  background-size: 60px 60px, 80px 80px, 40px 40px;
}

.login-card {
  width: 420px;
  padding: 48px 40px 36px;
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  position: relative;
  z-index: 1;

  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 50%;
    transform: translateX(-50%);
    width: 60px;
    height: 3px;
    background: #E74C3C;
    border-radius: 0 0 3px 3px;
  }
}

.login-header {
  text-align: center;
  margin-bottom: 36px;

  .brand-icon {
    width: 56px;
    height: 56px;
    margin: 0 auto 16px;

    svg {
      width: 100%;
      height: 100%;
    }
  }

  h1 {
    font-size: 26px;
    font-weight: 700;
    color: #2C3E50;
    margin-bottom: 6px;
    letter-spacing: 2px;
  }

  .subtitle {
    color: #E74C3C;
    font-size: 13px;
    font-weight: 500;
    letter-spacing: 4px;
    margin-bottom: 4px;
  }

  .desc {
    color: #909399;
    font-size: 12px;
  }
}

.login-form {
  .el-input {
    --el-input-border-radius: 8px;
  }
}

.login-btn {
  width: 100%;
  height: 44px;
  font-size: 15px;
  letter-spacing: 4px;
  border-radius: 8px;
  background: linear-gradient(135deg, #2C3E50, #34495E);
  border: none;

  &:hover {
    background: linear-gradient(135deg, #34495E, #2C3E50);
  }
}

.login-footer {
  text-align: center;
  margin-top: 20px;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;

  span {
    font-size: 12px;
    color: #c0c4cc;
  }
}
</style>
