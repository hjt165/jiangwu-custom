import request from './index'

/**
 * 获取交易统计数据
 */
export function getTransactionStats(params) {
  return request.get('/stats/transaction', { params })
}

/**
 * 获取用户行为数据
 */
export function getUserStats(params) {
  return request.get('/stats/user', { params })
}

/**
 * 获取首页概览数据
 */
export function getDashboardData() {
  return request.get('/stats/dashboard')
}
