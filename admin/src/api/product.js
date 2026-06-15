import request from './index'

/**
 * 获取作品列表
 */
export function getProductList(params) {
  return request.get('/product/list', { params })
}

/**
 * 获取作品详情
 */
export function getProductDetail(id) {
  return request.get(`/product/${id}`)
}

/**
 * 审核作品
 */
export function auditProduct(id, data) {
  return request.put(`/product/${id}/audit`, data)
}
