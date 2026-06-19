<template>
  <div class="sidebar" :class="{ collapsed: appStore.sidebarCollapsed }">
    <div class="sidebar-logo">
      <img src="" alt="Logo" class="logo-icon" />
      <span v-show="!appStore.sidebarCollapsed" class="logo-title">管理后台</span>
    </div>

    <el-menu
      :default-active="route.path"
      :collapse="appStore.sidebarCollapsed"
      router
      background-color="#2C3E50"
      text-color="#BFCCDF"
      active-text-color="#fff"
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
  background: #2C3E50;
  transition: width 0.3s;
  overflow: hidden;

  &.collapsed {
    width: 64px;
  }
}

.sidebar-logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.logo-icon {
  width: 32px;
  height: 32px;
}

.logo-title {
  font-size: 16px;
  font-weight: 700;
  color: #fff;
  white-space: nowrap;
}

.el-menu {
  border-right: none;
}
</style>
