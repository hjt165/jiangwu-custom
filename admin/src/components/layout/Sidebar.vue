<template>
  <div class="sidebar" :class="{ collapsed: appStore.sidebarCollapsed }">
    <div class="sidebar-logo">
      <div class="logo-icon-wrap">
        <svg viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
          <rect x="2" y="2" width="28" height="28" rx="6" fill="#E74C3C"/>
          <path d="M10 24V14l7 5-7 5z" fill="#fff"/>
          <path d="M17 14v10l7-5-7-5z" fill="#fff" opacity="0.7"/>
        </svg>
      </div>
      <span v-show="!appStore.sidebarCollapsed" class="logo-title">匠物定制</span>
    </div>

    <el-menu
      :default-active="route.path"
      :collapse="appStore.sidebarCollapsed"
      router
      background-color="transparent"
      text-color="rgba(255,255,255,0.65)"
      active-text-color="#fff"
      class="sidebar-menu"
    >
      <el-menu-item index="/dashboard">
        <el-icon><Odometer /></el-icon>
        <span>工作台</span>
      </el-menu-item>

      <el-sub-menu index="user">
        <template #title>
          <el-icon><User /></el-icon>
          <span>用户管理</span>
        </template>
        <el-menu-item index="/user/list">用户列表</el-menu-item>
      </el-sub-menu>

      <el-sub-menu index="order">
        <template #title>
          <el-icon><Document /></el-icon>
          <span>订单管理</span>
        </template>
        <el-menu-item index="/order/list">订单列表</el-menu-item>
        <el-menu-item index="/order/dispute">争议仲裁</el-menu-item>
      </el-sub-menu>

      <el-menu-item index="/product/list">
        <el-icon><Goods /></el-icon>
        <span>作品管理</span>
      </el-menu-item>

      <el-menu-item index="/artisan/list">
        <el-icon><Avatar /></el-icon>
        <span>手作人管理</span>
      </el-menu-item>

      <el-sub-menu index="content">
        <template #title>
          <el-icon><Picture /></el-icon>
          <span>内容管理</span>
        </template>
        <el-menu-item index="/content/image">图片审核</el-menu-item>
        <el-menu-item index="/content/comment">评论审核</el-menu-item>
      </el-sub-menu>

      <el-sub-menu index="stats">
        <template #title>
          <el-icon><DataAnalysis /></el-icon>
          <span>数据统计</span>
        </template>
        <el-menu-item index="/stats/transaction">交易统计</el-menu-item>
        <el-menu-item index="/stats/user">用户行为</el-menu-item>
      </el-sub-menu>

      <el-menu-item index="/settings">
        <el-icon><Setting /></el-icon>
        <span>系统设置</span>
      </el-menu-item>
    </el-menu>
  </div>
</template>

<script setup>
import { useRoute } from 'vue-router'
import { useAppStore } from '@/store/app'

const route = useRoute()
const appStore = useAppStore()
</script>

<style lang="scss" scoped>
.sidebar {
  width: 220px;
  height: 100vh;
  background: linear-gradient(180deg, #1a252f 0%, #2C3E50 100%);
  transition: width 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  overflow: hidden;
  display: flex;
  flex-direction: column;

  &.collapsed {
    width: 64px;
  }
}

.sidebar-logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  flex-shrink: 0;
}

.logo-icon-wrap {
  width: 32px;
  height: 32px;
  flex-shrink: 0;

  svg {
    width: 100%;
    height: 100%;
  }
}

.logo-title {
  font-size: 16px;
  font-weight: 700;
  color: #fff;
  white-space: nowrap;
  letter-spacing: 1px;
}

.sidebar-menu {
  flex: 1;
  overflow-y: auto;
  border-right: none;
  padding: 8px 0;

  :deep(.el-menu-item),
  :deep(.el-sub-menu__title) {
    height: 44px;
    line-height: 44px;
    margin: 2px 8px;
    border-radius: 8px;
    transition: all 0.2s;

    &:hover {
      background: rgba(255, 255, 255, 0.08) !important;
    }
  }

  :deep(.el-menu-item.is-active) {
    background: linear-gradient(135deg, #E74C3C, #c0392b) !important;
    color: #fff !important;
    box-shadow: 0 2px 8px rgba(231, 76, 60, 0.3);
  }

  :deep(.el-sub-menu .el-menu-item) {
    min-width: auto;
    padding-left: 52px !important;
    margin: 2px 8px;
    border-radius: 6px;
    height: 40px;
    line-height: 40px;
    font-size: 13px;
  }

  :deep(.el-sub-menu.is-opened > .el-sub-menu__title) {
    color: #fff !important;
  }
}

:deep(.el-menu--collapse) {
  .sidebar-menu {
    :deep(.el-menu-item),
    :deep(.el-sub-menu__title) {
      margin: 2px 8px;
    }
  }
}
</style>
