<template>
  <el-table v-bind="$attrs" :data="data" stripe v-loading="loading">
    <slot />
    <template #empty>
      <div class="empty-state">
        <el-empty description="暂无数据" />
      </div>
    </template>
  </el-table>
</template>

<script setup>
defineProps({
  data: { type: Array, default: () => [] },
  loading: { type: Boolean, default: false },
})
</script>
