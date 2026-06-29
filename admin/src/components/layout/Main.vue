<template>
  <div class="layout">
    <Sidebar />
    <div class="layout-main">
      <Header />
      <div class="layout-content">
        <router-view />
      </div>
    </div>
  </div>
</template>

<script setup>
import Header from './Header.vue'
import Sidebar from './Sidebar.vue'
</script>

<style lang="scss" scoped>
.layout {
  display: flex;
  height: 100vh;
  overflow: hidden;
}

.layout-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  min-width: 0;
}

.layout-content {
  flex: 1;
  overflow-y: auto;
  background: #FAFAF9;
}
</style>
