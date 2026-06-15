<template>
  <el-tag :type="tagType" :effect="effect">{{ label }}</el-tag>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  status: { type: String, required: true },
  effect: { type: String, default: 'light' },
})

const statusMap = {
  pending_payment: { label: '待支付', type: 'warning' },
  paid: { label: '已支付', type: 'primary' },
  producing: { label: '制作中', type: '' },
  stage_delivering: { label: '阶段交付中', type: 'primary' },
  completed: { label: '已完成', type: 'success' },
  cancelled: { label: '已取消', type: 'info' },
  refunding: { label: '退款中', type: 'danger' },
  delayed: { label: '延期中', type: 'warning' },
  disputed: { label: '争议中', type: 'danger' },
}

const label = computed(() => statusMap[props.status]?.label || props.status)
const tagType = computed(() => statusMap[props.status]?.type || 'info')
</script>
