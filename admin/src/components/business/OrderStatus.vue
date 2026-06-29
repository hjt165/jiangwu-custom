<template>
  <span class="order-status" :class="'os-' + statusClass">
    {{ label }}
  </span>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  status: { type: String, required: true },
})

const statusMap = {
  pending_payment: { label: '待付款', cls: 'warning' },
  paid: { label: '已付款', cls: 'info' },
  producing: { label: '制作中', cls: '' },
  stage_delivering: { label: '阶段交付', cls: 'info' },
  completed: { label: '已完成', cls: 'success' },
  cancelled: { label: '已取消', cls: 'disabled' },
  refunding: { label: '退款中', cls: 'danger' },
  delayed: { label: '已逾期', cls: 'warning' },
  disputed: { label: '争议中', cls: 'danger' },
}

const label = computed(() => statusMap[props.status]?.label || props.status)
const statusClass = computed(() => statusMap[props.status]?.cls || '')
</script>

<style lang="scss" scoped>
.order-status {
  display: inline-block;
  padding: 2px 10px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;

  &.os-success {
    background: #E8FAE8;
    color: #27AE60;
  }

  &.os-warning {
    background: #FEF0E6;
    color: #E67E22;
  }

  &.os-danger {
    background: #FDE8E8;
    color: #E74C3C;
  }

  &.os-info {
    background: #E8F4FD;
    color: #3498DB;
  }

  &.os-disabled {
    background: #F5F5F5;
    color: #C0C4CC;
  }

  &.os- {
    background: #F5F5F5;
    color: #606266;
  }
}
</style>
