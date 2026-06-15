<template>
  <el-pagination
    v-bind="$attrs"
    :page-size="pageSize"
    :total="total"
    layout="total, prev, pager, next, jumper"
    @current-change="(page) => $emit('update:page', page)"
  />
</template>

<script setup>
defineProps({
  total: { type: Number, default: 0 },
  pageSize: { type: Number, default: 10 },
})
defineEmits(['update:page'])
</script>

<style scoped>
.el-pagination {
  margin-top: 20px;
  justify-content: flex-end;
}
</style>
