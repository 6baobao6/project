<template>
  <div class="login-container">
    <div class="login-content">
      <el-card class="login-card">
        <h2 class="title">{{ isRegister ? 'Register' : 'Login' }}</h2>
        <el-form :model="form" ref="formRef" label-width="80px" class="login-form" @submit.native.prevent="handleSubmit">
          <el-form-item label="Username" prop="username" :rules="usernameRules">
            <el-input v-model="form.username" placeholder="Enter your username" />
          </el-form-item>

          <el-form-item v-if="isRegister" label="Email" prop="email" :rules="emailRules">
            <el-input v-model="form.email" placeholder="Enter your email" />
          </el-form-item>

          <el-form-item label="Password" prop="password" :rules="passwordRules">
            <el-input type="password" v-model="form.password" placeholder="Enter your password" />
          </el-form-item>

          <el-form-item>
            <el-button type="primary" native-type="submit" class="login-button" :loading="loading">
              {{ isRegister ? 'Register' : 'Login' }}
            </el-button>
          </el-form-item>
        </el-form>

        <div class="toggle-form">
          <span @click="toggleForm">
            {{ isRegister ? 'Already have an account? Login' : 'Don\'t have an account? Register' }}
          </span>
        </div>
         <!-- 添加跳转到管理员登录页面的超链接 -->
         <div class="admin-link">
          <a href="/admin_login">Admin Login</a> <!-- 这里的 href 路径根据你的路由设置进行调整 -->
        </div>
      </el-card>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue';
import axios from 'axios';
import { ElMessage } from 'element-plus';
import { useRouter } from 'vue-router'; // 引入 useRouter

export default {
  name: 'Login',
  setup() {
    const formRef = ref(null);
    const loading = ref(false);
    const isRegister = ref(false); // 控制当前是登录还是注册
    const form = ref({
      username: '',
      password: '',
      email: '',
    });

    const usernameRules = [
      { required: true, message: 'Username is required', trigger: 'blur' }
    ];

    const passwordRules = [
      { required: true, message: 'Password is required', trigger: 'blur' }
    ];

    const emailRules = [
      { required: isRegister.value, message: 'Email is required', trigger: 'blur' },
      { type: 'email', message: 'Invalid email', trigger: ['blur', 'change'] }
    ];

    const router = useRouter(); // 获取 router 实例

    const toggleForm = () => {
      isRegister.value = !isRegister.value;
      form.value.email = '';  // 切换时重置邮箱
      formRef.value.resetFields(); // 重置表单
    };

    const handleSubmit = async () => {
      formRef.value.validate(async (valid) => {
        if (valid) {
          loading.value = true;
          try {
            const userType = isRegister.value ? 'register' : 'login';
            const response = await axios.post(`http://localhost:5000/${userType}`, {
              username: form.value.username,
              password: form.value.password,
              email: isRegister.value ? form.value.email : undefined
            });

            // 假设JWT存储在response.data.token中
            const token = response.data.token;
            localStorage.setItem('jwt', token); // 保存JWT到本地存储

            ElMessage.success(isRegister.value ? 'Registration successful!' : 'Login successful!');
            // 登录或注册成功后的页面跳转
            router.push({ path: 'reader/introduce' }); // 跳转到主页
          } catch (error) {
            ElMessage.error(error.response?.data || 'An error occurred');
          } finally {
            loading.value = false;
          }
        }
      });
    };

    return {
      formRef,
      loading,
      isRegister,
      form,
      usernameRules,
      passwordRules,
      emailRules,
      toggleForm,
      handleSubmit,
    };
  }
};
</script>

<style scoped>
.toggle-form {
  text-align: center;
  margin-top: 20px;
  cursor: pointer;
}
.login-container {
  position: fixed;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  height: 100%;
  width: 100%;
  background: url('../assets/cool-background3.png') no-repeat center center;
  background-size: cover;
}
.login-content {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 100%;
}
.login-card {
  width: 400px;
  padding: 30px;
  background: rgba(255, 255, 255, 0.8);
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}
.title {
  text-align: center;
  font-size: 24px;
  margin-bottom: 20px;
}
.login-form .el-form-item {
  margin-bottom: 20px;
}
.login-button {
  width: 100%;
}
.admin-link {
  text-align: right; /* 右对齐 */
  margin-top: 20px; /* 上边距 */
}
</style>
