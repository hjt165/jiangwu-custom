import request from './index'

/**
 * 获取手作人列表
 */
export function getArtisanList(params) {
  return request.get('/artisan/list', { params })
}

/**
 * 获取手作人详情
 */
export function getArtisanDetail(id) {
  return request.get(`/artisan/${id}`)
}

/**
 * 审核手作人申请
 */
export function auditArtisan(id, data) {
  return request.put(`/artisan/${id}/audit`, data)
}
