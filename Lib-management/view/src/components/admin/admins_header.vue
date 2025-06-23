<template>
  <div class="menu-container">
    <el-menu
      :default-active="activeIndex"
      class="el-menu-demo"
      mode="horizontal"
      :ellipsis="false"
      @select="handleSelect"
    >
      <RouterLink to="/admin/introduce">
        <el-menu-item index="1">
          <template #title>Library Management System</template>
        </el-menu-item>
      </RouterLink>
      <el-sub-menu index="1">
        <template #title>Book Management</template>
        <RouterLink to="/admin/book"><el-menu-item index="1-1">All Books</el-menu-item></RouterLink>
        <RouterLink to="/admin/bookadd"><el-menu-item index="1-2">Book Add</el-menu-item></RouterLink>
      </el-sub-menu>

      <el-sub-menu index="3">
        <template #title>Lending Management</template>
        <RouterLink to="/admin/lendlist"><el-menu-item index="3-1">Lend List</el-menu-item></RouterLink>
      </el-sub-menu>
      <RouterLink to="/admin/repassword"><el-menu-item index="4">
        <template #title>Modify Password</template>
      </el-menu-item></RouterLink>
      <el-menu-item index="5" @click="showUsernameDialog = true">
        <template #title>{{ admin }}</template>
      </el-menu-item>
      <el-menu-item index="6" @click="handleLogout">
        <template #title>Log Out</template>
      </el-menu-item>
    </el-menu>

    <!-- 用户名模态框 -->
    <el-dialog
      title="User Information"
      v-model="showUsernameDialog"
      width="30%"
    >
      <p>Username: {{ admin }}</p>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue';
import { RouterLink } from 'vue-router';
import { useRouter } from 'vue-router';
import axios from 'axios';

const activeIndex = ref('1');
const router = useRouter();
const showUsernameDialog = ref(false);
const admin = ref(''); // 示例用户名，实际应用中应从状态管理或 API 获取
const token = localStorage.getItem('jwt'); // 确保在登录后设置 token

const handleSelect = (key: string, keyPath: string[]) => {
  console.log(key, keyPath);
}

const handleLogout = () => {
  // 清除用户状态，例如 tokens，localStorage，sessionStorage 等
  localStorage.removeItem('user');

  // 重定向到登录页面
  router.push({ name: 'index' }); // 使用路由的名称进行重定向
}

const fetchUsername = async () => {
  if (!token) {
    console.error('No token found');
    return;
  }

  try {
    const response = await axios.get('http://localhost:5000/api/admin/current_user', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    admin.value = response.data.username; // 设置用户名
  } catch (error) {
    console.error('Failed to fetch username:');
  }
};

// 在组件挂载时从 localStorage 获取用户信息
onMounted(() => {
  fetchUsername();
  console.log(admin.value);
});
</script>

<style>
.menu-container {
  display: flex;
  justify-content: center; /* 水平居中 */
  align-items: center; /* 垂直居中 */
  width: 100%; /* 让容器占满整个宽度 */
}

.el-menu-demo {
  display: flex; /* 使用 Flexbox 进行布局 */
  justify-content: center; /* 水平居中整个菜单 */
  width: 100%; /* 让菜单宽度为100% */
}

.el-menu-demo > * {
  margin: 0 10px; /* 给每个项目添加水平间距 */
}

.el-menu-item {
  text-align: center; /* 使单个菜单项的文本居中 */
}

.el-menu--horizontal {
  display: flex; /* 使用 Flexbox 进行布局 */
  justify-content: space-around;
}

.el-menu--horizontal > .el-menu-item {
  margin: 0 15px; /* 增加菜单项之间的间距 */
}

.el-menu--horizontal > .el-sub-menu {
  margin: 0 15px; /* 增加子菜单项之间的间距 */
}


</style>
