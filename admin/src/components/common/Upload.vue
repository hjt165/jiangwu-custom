<template>
  <el-upload v-bind="$attrs" :before-upload="beforeUpload" :on-exceed="handleExceed">
    <slot>
      <el-button type="primary">
        <el-icon><Upload /></el-icon>
        点击上传
      </el-button>
    </slot>
  </el-upload>
</template>

<script setup>
import { ElMessage } from 'element-plus'

const props = defineProps({
  maxSize: { type: Number, default: 10 },
  accept: { type: Array, default: () => ['image/jpeg', 'image/png'] },
})

function beforeUpload(file) {
  const isValidType = props.accept.includes(file.type)
  if (!isValidType) {
    ElMessage.error('文件格式不支持')
    return false
  }
  const isValidSize = file.size / 1024 / 1024 < props.maxSize
  if (!isValidSize) {
    ElMessage.error(`文件大小不能超过 ${props.maxSize}MB`)
    return false
  }
  return true
}

function handleExceed() {
  ElMessage.warning('文件数量超出限制')
}
</script>
