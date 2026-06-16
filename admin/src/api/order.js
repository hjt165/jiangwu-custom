import request from './index'

/**
 * 获取订单列表
 */
export function getOrderList(params) {
  return request.get('/admin/order/list', { params })
}

/**
 * 获取订单详情
 */
export function getOrderDetail(id) {
  return request.get(`/admin/order/${id}`)
}

/**
 * 获取争议订单列表
 */
export function getDisputeList(params) {
  return request.get('/admin/order/dispute', { params })
}

/**
 * 仲裁争议订单
 */
export function resolveDispute(orderId, data) {
  return request.put(`/admin/order/${orderId}/dispute`, data)
}
