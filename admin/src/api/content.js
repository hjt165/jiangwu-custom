import request from './index'

/**
 * 获取待审核图片列表
 */
export function getImageReviewList(params) {
  return request.get('/content/image/list', { params })
}

/**
 * 审核图片
 */
export function reviewImage(id, data) {
  return request.put(`/content/image/${id}/review`, data)
}

/**
 * 获取待审核评论列表
 */
export function getCommentReviewList(params) {
  return request.get('/content/comment/list', { params })
}

/**
 * 审核评论
 */
export function reviewComment(id, data) {
  return request.put(`/content/comment/${id}/review`, data)
}
