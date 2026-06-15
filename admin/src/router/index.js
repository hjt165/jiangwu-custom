import { createRouter, createWebHistory } from 'vue-router'
import { getToken } from '@/utils/auth'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/login/index.vue'),
    meta: { title: '登录' },
  },
  {
    path: '/',
    component: () => import('@/components/layout/Main.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/dashboard/index.vue'),
        meta: { title: '工作台' },
      },
      {
        path: 'user/list',
        name: 'UserList',
        component: () => import('@/views/user/list.vue'),
        meta: { title: '用户列表' },
      },
      {
        path: 'user/:id',
        name: 'UserDetail',
        component: () => import('@/views/user/detail.vue'),
        meta: { title: '用户详情' },
      },
      {
        path: 'order/list',
        name: 'OrderList',
        component: () => import('@/views/order/list.vue'),
        meta: { title: '订单列表' },
      },
      {
        path: 'order/:id',
        name: 'OrderDetail',
        component: () => import('@/views/order/detail.vue'),
        meta: { title: '订单详情' },
      },
      {
        path: 'order/dispute',
        name: 'OrderDispute',
        component: () => import('@/views/order/dispute.vue'),
        meta: { title: '争议仲裁' },
      },
      {
        path: 'content/image',
        name: 'ContentImage',
        component: () => import('@/views/content/image.vue'),
        meta: { title: '图片审核' },
      },
      {
        path: 'content/comment',
        name: 'ContentComment',
        component: () => import('@/views/content/comment.vue'),
        meta: { title: '评论审核' },
      },
      {
        path: 'stats/transaction',
        name: 'StatsTransaction',
        component: () => import('@/views/stats/transaction.vue'),
        meta: { title: '交易统计' },
      },
      {
        path: 'stats/user',
        name: 'StatsUser',
        component: () => import('@/views/stats/user.vue'),
        meta: { title: '用户行为分析' },
      },
      {
        path: 'settings',
        name: 'Settings',
        component: () => import('@/views/settings/index.vue'),
        meta: { title: '系统设置' },
      },
    ],
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

// 导航守卫
router.beforeEach((to, from, next) => {
  document.title = `${to.meta.title || ''} - 匠物定制管理后台`
  const token = getToken()

  if (to.path === '/login') {
    next()
  } else if (!token) {
    next('/login')
  } else {
    next()
  }
})

export default router
