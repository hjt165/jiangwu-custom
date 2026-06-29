<template>
  <div class="sidebar" :class="{ collapsed: appStore.sidebarCollapsed }">
    <div class="sidebar-logo">
      <div class="logo-icon-wrap">
        <svg viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
          <rect x="2" y="2" width="28" height="28" rx="6" stroke="#2C3E50" stroke-width="1.5"/>
          <path d="M10 24V14l7 5-7 5z" fill="#2C3E50"/>
          <path d="M17 14v10l7-5-7-5z" fill="#E74C3C" opacity="0.8"/>
        </svg>
      </div>
      <span v-show="!appStore.sidebarCollapsed" class="logo-title">匠物定制</span>
    </div>

    <el-menu
      :default-active="route.path"
      :collapse="appStore.sidebarCollapsed"
      router
      background-color="transparent"
      text-color="#606266"
      active-text-color="#2C3E50"
      class="sidebar-menu"
    >
      <el-menu-item index="/dashboard">
        <el-icon><Odometer /></el-icon>
        <template #title><span>概览</span></template>
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
        <el-menu-item index="/order/dispute">争议处理</el-menu-item>
      </el-sub-menu>

      <el-menu-item index="/product/list">
        <el-icon><Goods /></el-icon>
        <template #title><span>商品管理</span></template>
      </el-menu-item>

      <el-menu-item index="/artisan/list">
        <el-icon><Avatar /></el-icon>
        <template #title><span>手作人</span></template>
      </el-menu-item>

      <el-sub-menu index="content">
        <template #title>
          <el-icon><Picture /></el-icon>
          <span>内容管理</span>
        </template>
        <el-menu-item index="/content/image">图片审核</el-menu-item>
        <el-menu-item index="/content/comment">评论管理</el-menu-item>
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
        <template #title><span>系统设置</span></template>
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
  background: #fff;
  border-right: 1px solid #F0F0F0;
  transition: width 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  overflow: hidden;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;

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
  padding: 0 16px;
  border-bottom: 1px solid #F0F0F0;
  flex-shrink: 0;
}

.logo-icon-wrap {
  width: 28px;
  height: 28px;
  flex-shrink: 0;

  svg {
    width: 100%;
    height: 100%;
  }
}

.logo-title {
  font-size: 15px;
  font-weight: 700;
  color: #2C3E50;
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
    height: 42px;
    line-height: 42px;
    margin: 1px 6px;
    border-radius: 6px;
    transition: all 0.15s;
    font-size: 14px;
    color: #606266;

    &:hover {
      background: #F5F5F0 !important;
    }
  }

  :deep(.el-menu-item.is-active) {
    background: #F5F5F0 !important;
    color: #2C3E50 !important;
    font-weight: 500;

    &::after {
      content: '';
      position: absolute;
      left: 0;
      top: 50%;
      transform: translateY(-50%);
      width: 3px;
      height: 16px;
      background: #2C3E50;
      border-radius: 0 2px 2px 0;
    }
  }

  :deep(.el-sub-menu .el-menu-item) {
    padding-left: 52px !important;
    margin: 1px 6px;
    border-radius: 6px;
    height: 38px;
    line-height: 38px;
    font-size: 13px;
  }

  :deep(.el-sub-menu.is-opened > .el-sub-menu__title) {
    color: #2C3E50 !important;
  }
}
</style>
