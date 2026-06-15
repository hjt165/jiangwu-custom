import { defineStore } from 'pinia'
import { ref } from 'vue'
import { getToken, setToken, removeToken, getUser, setUser, removeUser } from '@/utils/auth'
import { adminLogin } from '@/api/user'
import router from '@/router'

export const useUserStore = defineStore('user', () => {
  const token = ref(getToken() || '')
  const userInfo = ref(getUser() || {})

  /**
   * 登录
   */
  async function login(loginForm) {
    const res = await adminLogin(loginForm)
    token.value = res.data.token
    userInfo.value = res.data
    setToken(res.data.token)
    setUser(res.data)
    router.push('/')
  }

  /**
   * 登出
   */
  function logout() {
    token.value = ''
    userInfo.value = {}
    removeToken()
    removeUser()
    router.push('/login')
  }

  return { token, userInfo, login, logout }
})
