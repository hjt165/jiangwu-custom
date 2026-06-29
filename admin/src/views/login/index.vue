<template>
  <div class="login-page">
    <div class="login-left">
      <div class="brand">
        <svg class="brand-mark" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg">
          <rect x="2" y="2" width="36" height="36" rx="6" stroke="#2C3E50" stroke-width="1.5"/>
          <path d="M12 32V16l8 6-8 6z" fill="#2C3E50"/>
          <path d="M20 16v8l8-6-8-6z" fill="#E74C3C" opacity="0.8"/>
        </svg>
        <div class="brand-text">
          <span class="brand-name">匠物定制</span>
          <span class="brand-en">JIAN GWU CUSTOM</span>
        </div>
      </div>
      <div class="brand-quote">
        <p>"器物有魂魄，匠心自可观"</p>
        <span>— 匠物定制 · 管理后台</span>
      </div>
    </div>

    <div class="login-right">
      <div class="login-form-wrap">
        <h2 class="login-title">管理后台</h2>
        <p class="login-subtitle">请登录您的管理员账户</p>

        <el-form ref="formRef" :model="form" :rules="rules" class="login-form" @keyup.enter="handleLogin">
          <el-form-item prop="phone">
            <el-input
              v-model="form.phone"
              placeholder="请输入手机号"
              size="large"
              prefix-icon="User"
              class="login-input"
            />
          </el-form-item>

          <el-form-item prop="password">
            <el-input
              v-model="form.password"
              type="password"
              placeholder="请输入密码"
              size="large"
              prefix-icon="Lock"
              show-password
              class="login-input"
            />
          </el-form-item>

          <el-form-item>
            <el-button
              type="primary"
              size="large"
              :loading="loading"
              class="login-submit"
              @click="handleLogin"
            >
              登 录
            </el-button>
          </el-form-item>
        </el-form>

        <div class="login-hint">
          测试账号：13800000000 / admin123
        </div>
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
.login-page {
  width: 100%;
  height: 100vh;
  display: flex;
  overflow: hidden;
  background: #FAFAF9;
}

/* ========== 左侧品牌区 ========== */
.login-left {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  padding: 60px 72px;
  background: #2C3E50;
  position: relative;
  overflow: hidden;
}

.login-left::after {
  content: '';
  position: absolute;
  top: -20%;
  right: -20%;
  width: 600px;
  height: 600px;
  border-radius: 50%;
  background: rgba(231, 76, 60, 0.06);
  pointer-events: none;
}

.brand {
  display: flex;
  align-items: center;
  gap: 16px;
  position: relative;
  z-index: 1;
}

.brand-mark {
  width: 44px;
  height: 44px;
  flex-shrink: 0;
}

.brand-text {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.brand-name {
  font-size: 22px;
  font-weight: 700;
  color: #fff;
  letter-spacing: 3px;
}

.brand-en {
  font-size: 10px;
  color: rgba(255, 255, 255, 0.4);
  letter-spacing: 2px;
  text-transform: uppercase;
}

.brand-quote {
  position: relative;
  z-index: 1;

  p {
    font-size: 20px;
    color: rgba(255, 255, 255, 0.85);
    line-height: 1.6;
    margin-bottom: 8px;
    font-weight: 300;
  }

  span {
    font-size: 12px;
    color: rgba(255, 255, 255, 0.35);
    letter-spacing: 1px;
  }
}

/* ========== 右侧登录区 ========== */
.login-right {
  width: 520px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #FAFAF9;
  position: relative;
}

.login-right::before {
  content: '';
  position: absolute;
  left: 0;
  top: 10%;
  bottom: 10%;
  width: 1px;
  background: rgba(44, 62, 80, 0.08);
}

.login-form-wrap {
  width: 100%;
  padding: 0 60px;
}

.login-title {
  font-size: 28px;
  font-weight: 700;
  color: #2C3E50;
  margin: 0 0 6px;
  letter-spacing: 1px;
}

.login-subtitle {
  font-size: 14px;
  color: #909399;
  margin: 0 0 40px;
}

.login-form {
  :deep(.el-form-item) {
    margin-bottom: 20px;
  }
}

.login-input {
  :deep(.el-input__wrapper) {
    border-radius: 6px;
    padding: 0 16px;
    box-shadow: none;
    border: 1px solid #E4E7ED;
    background: #fff;
    transition: all 0.2s;

    &:hover {
      border-color: #2C3E50;
    }

    &.is-focus {
      border-color: #2C3E50;
      box-shadow: 0 0 0 2px rgba(44, 62, 80, 0.1);
    }
  }

  :deep(.el-input__prefix) {
    color: #909399;
  }
}

.login-submit {
  width: 100%;
  height: 46px;
  margin-top: 12px;
  font-size: 14px;
  letter-spacing: 6px;
  border-radius: 6px;
  background: #2C3E50;
  border: none;
  color: #fff;
  transition: all 0.2s;

  &:hover {
    background: #1A252F;
  }
}

.login-hint {
  margin-top: 24px;
  padding-top: 16px;
  border-top: 1px solid #F0F0F0;
  font-size: 12px;
  color: #C0C4CC;
  text-align: center;
}

/* ========== 响应式 ========== */
@media (max-width: 1024px) {
  .login-left {
    display: none;
  }

  .login-right {
    width: 100%;
  }
}
</style>
