<template>
  <div class="admin-container">
    <div class="admin-content">
      <el-card class="admin-card">
        <h2 class="title">{{ isRegister ? 'Admin Register' : 'Admin Login' }}</h2>
        <el-form :model="form" ref="formRef" label-width="80px" class="admin-form" @submit.native.prevent="handleSubmit">
          <el-form-item label="Username" prop="username" :rules="usernameRules">
            <el-input v-model="form.username" placeholder="Enter admin username" />
          </el-form-item>

          <el-form-item v-if="isRegister" label="Security Code" prop="securityCode" :rules="securityCodeRules">
            <el-input v-model="form.securityCode" placeholder="Enter security code" />
          </el-form-item>

          <el-form-item label="Password" prop="password" :rules="passwordRules">
            <el-input type="password" v-model="form.password" placeholder="Enter admin password" />
          </el-form-item>

          <el-form-item>
            <el-button type="primary" native-type="submit" class="admin-button" :loading="loading">
              {{ isRegister ? 'Register' : 'Login' }}
            </el-button>
          </el-form-item>
        </el-form>
        <div class="toggle-form" @click="toggleForm">
          {{ isRegister ? 'Already have an account? Login' : 'New admin? Register' }}
        </div>
        <!-- 添加跳转到用户登录页面的超链接 -->
        <div class="reader-link">
          <a href="/">Reader Login</a> <!-- 这里的 href 路径根据你的路由设置进行调整 -->
        </div>
      </el-card>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue';
import axios from 'axios';
import { ElMessage } from 'element-plus';
import { useRouter } from 'vue-router';

export default {
  name: 'AdminAuth',
  setup() {
    const formRef = ref(null);
    const loading = ref(false);
    const isRegister = ref(false);

    const form = ref({
      username: '',
      password: '',
      securityCode: '',
    });

    const usernameRules = [
      { required: true, message: 'Username is required', trigger: 'blur' }
    ];

    const passwordRules = [
      { required: true, message: 'Password is required', trigger: 'blur' }
    ];

    const securityCodeRules = [
      { required: isRegister.value, message: 'Security Code is required', trigger: 'blur' },
      { validator: (rule, value, callback) => {
          if (isRegister.value && value !== '12345678') {
            callback(new Error('Invalid security code.'));
          } else {
            callback();
          }
        }, trigger: 'blur' }
    ];

    const router = useRouter();

    const handleSubmit = async () => {
      formRef.value.validate(async (valid) => {
        if (valid) {
          loading.value = true;
          try {
            const endpoint = isRegister.value ? 'http://localhost:5000/admin/register' : 'http://localhost:5000/admin/login';
            const response = await axios.post(endpoint, {
              username: form.value.username,
              password: form.value.password,
              ...(isRegister.value && { securityCode: form.value.securityCode }),
            });
            ElMessage.success(isRegister.value ? 'Registration successful!' : 'Login successful!');
            const token = response.data.token;
            localStorage.setItem('jwt', token); // 保存JWT到本地存储
            router.push({ path: 'admin/introduce' });
          } catch (error) {
            ElMessage.error(error.response?.data || 'An error occurred');
          } finally {
            loading.value = false;
          }
        }
      });
    };

    const toggleForm = () => {
      isRegister.value = !isRegister.value;
      form.value.securityCode = '';  // Reset security code on toggle
    };

    return {
      formRef,
      loading,
      form,
      usernameRules,
      passwordRules,
      securityCodeRules,
      handleSubmit,
      toggleForm,
      isRegister,
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
.admin-container {
  position: fixed;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  height: 100%;
  width: 100%;
  background: url('../assets/cool-background1.png') no-repeat center center;
  background-size: cover;
}
.admin-content {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 100%;
}
.admin-card {
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
.admin-form .el-form-item {
  margin-bottom: 20px;
}
.admin-button {
  width: 100%;
}
.admin-link {
  text-align: right; /* 右对齐 */
  margin-top: 20px; /* 上边距 */
}

.reader-link {
  text-align: right; /* 右对齐 */
  margin-top: 20px; /* 上边距 */
}
</style>
