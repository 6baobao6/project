import { createRouter, createWebHistory } from 'vue-router'
import Reader from '../views/reader_main.vue'
import path from 'path'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/reader',
      name: 'reader',
      component: Reader,
      children:[{
        path: 'repassword',
        component: () => import('../components/repasswd.vue')
      },
    {
      path:'info',
      component: () => import('../components/reader/readers_info.vue')
    },
      {
        path:'lendlist',
        component: () => import('../components/reader/readers_lend_list.vue')
      },
    {
      path:'book',
      component: () => import('../components/reader/readers_books.vue')
    },
    {
      path:'introduce',
      component: () => import('../components/reader/readers_introduce.vue')
    }]
    },
    {
      path: '/admin',
      name: 'admin',
      component: () => import('../views/admin_main.vue'),
      children:[{
        path: 'repassword',
        component: () => import('../components/repasswd.vue')
      },
    {
        path:'lendlist',
        component: () => import('../components/admin/admins_lend_list.vue')
    },
    {
      path:'book',
      component: () => import('../components/admin/admins_books.vue')
    },
    {
      path:'bookadd',
      component: () => import('../components/admin/admins_books_add.vue')
    },
    {
      path:'introduce',
      component: () => import('../components/admin/admins_introduce.vue')
    }
  ]
    },
    {
      path: '/',
      name: 'index',
      component: () => import('../views/index.vue')
    },
    {
      path: '/admin_login',
      name: 'admin_login',
      component: () => import('../views/admin_login.vue')
    }
  ]
})

export default router
