<template>
  <div class="header">
    <div class="header-left">
      <el-icon class="collapse-btn" @click="appStore.toggleSidebar">
        <Fold v-if="!appStore.sidebarCollapsed" />
        <Expand v-else />
      </el-icon>
      <span class="page-title">{{ currentTitle }}</span>
    </div>

    <div class="header-right">
      <el-dropdown @command="handleCommand">
        <span class="user-info">
          <el-avatar :size="30" class="user-avatar">
            {{ userStore.userInfo.nickname?.charAt(0) || 'A' }}
          </el-avatar>
          <span class="username">{{ userStore.userInfo.nickname || '管理员' }}</span>
          <el-icon class="arrow"><ArrowDown /></el-icon>
        </span>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item command="logout">
              <el-icon><SwitchButton /></el-icon>
              退出登录
            </el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useUserStore } from '@/store/user'
import { useAppStore } from '@/store/app'

const route = useRoute()
const userStore = useUserStore()
const appStore = useAppStore()

const titleMap = {
  '/dashboard': '概览',
  '/user/list': '用户列表',
  '/order/list': '订单列表',
  '/order/dispute': '争议处理',
  '/product/list': '商品管理',
  '/artisan/list': '手作人管理',
  '/content/image': '图片审核',
  '/content/comment': '评论管理',
  '/stats/transaction': '交易统计',
  '/stats/user': '用户行为',
  '/settings': '系统设置',
}

const currentTitle = computed(() => {
  if (titleMap[route.path]) return titleMap[route.path]
  if (route.path.startsWith('/user/')) return '用户详情'
  if (route.path.startsWith('/order/')) return '订单详情'
  if (route.path.startsWith('/product/')) return '商品详情'
  if (route.path.startsWith('/artisan/')) return '手作人详情'
  return '管理后台'
})

function handleCommand(command) {
  if (command === 'logout') {
    userStore.logout()
  }
}
</script>

<style lang="scss" scoped>
.header {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  background: #fff;
  border-bottom: 1px solid #F0F0F0;
  position: relative;
  z-index: 10;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.collapse-btn {
  font-size: 18px;
  cursor: pointer;
  color: #909399;
  transition: color 0.2s;
  padding: 4px;
  border-radius: 4px;

  &:hover {
    color: #2C3E50;
  }
}

.page-title {
  font-size: 15px;
  font-weight: 600;
  color: #2C3E50;
}

.header-right {
  display: flex;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 6px;
  transition: background 0.2s;

  &:hover {
    background: #F5F5F0;
  }
}

.user-avatar {
  background: #2C3E50;
  color: #fff;
  font-weight: 600;
  font-size: 13px;
}

.username {
  font-size: 13px;
  color: #303133;
  font-weight: 500;
}

.arrow {
  font-size: 12px;
  color: #C0C4CC;
}
</style>
