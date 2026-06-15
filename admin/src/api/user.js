import request from './index'

/**
 * 管理员登录
 */
export function adminLogin(data) {
  return request.post('/user/login', data)
}

/**
 * 获取用户列表
 */
export function getUserList(params) {
  return request.get('/user/list', { params })
}

/**
 * 获取用户详情
 */
export function getUserDetail(id) {
  return request.get(`/user/${id}`)
}

/**
 * 更新用户状态
 */
export function updateUserStatus(id, status) {
  return request.put(`/user/${id}/status`, { status })
}

/**
 * 更新用户信用分
 */
export function updateUserCredit(id, creditScore) {
  return request.put(`/user/${id}/credit`, { creditScore })
}
