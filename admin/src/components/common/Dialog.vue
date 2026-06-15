<template>
  <el-dialog v-bind="$attrs" :model-value="modelValue" @update:model-value="(val) => $emit('update:modelValue', val)" :close-on-click-modal="false" width="600px">
    <slot />
    <template #footer>
      <slot name="footer">
        <el-button @click="$emit('update:modelValue', false)">取消</el-button>
        <el-button type="primary" @click="$emit('confirm')">确定</el-button>
      </slot>
    </template>
  </el-dialog>
</template>

<script setup>
defineProps({
  modelValue: { type: Boolean, default: false },
})
defineEmits(['update:modelValue', 'confirm'])
</script>
