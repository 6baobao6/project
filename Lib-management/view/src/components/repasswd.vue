<template>
 <el-card class="repasswd" shadow="always">
  <span>Modify Password</span>
  <el-form :model="form" ref="formRef" label-width="120px" @submit.native.prevent="handleSubmit">
    <el-form-item label="Old Password" :rules="oldPasswordRules">
      <el-input
        v-model="form.oldPasswd"
        type="password"
        placeholder="Send your old password"
        :show-password="showOldPassword"
        @blur="handleBlur('oldPasswd')"
      />
    </el-form-item>

    <el-form-item label="New Password" :rules="newPasswordRules">
      <el-input
        v-model="form.newPasswd"
        type="password"
        placeholder="Send your new password"
        :show-password="showNewPassword"
        @blur="handleBlur('newPasswd')"
      />
    </el-form-item>

    <el-form-item label="comfirm password" :rules="confirmPasswordRules">
      <el-input
        v-model="form.reNewPasswd"
        type="password"
        placeholder="Send your new password again"
        :show-password="showConfirmPassword"
        @blur="handleBlur('reNewPasswd')"
      />
    </el-form-item>

    <el-form-item>
      <span id="error-message" style="color: red" v-if="errorMessage">{{ errorMessage }}</span>
    </el-form-item>

    <el-form-item>
      <el-button type="primary" @click="handleSubmit">Submit</el-button>
    </el-form-item>
  </el-form>
 </el-card>
</template>

<script>
import { ref } from 'vue';
import { ElForm, ElFormItem, ElInput, ElButton } from 'element-plus';

export default {
  name: 'PasswordChangeForm',
  components: {
    ElForm,
    ElFormItem,
    ElInput,
    ElButton
  },
  setup() {
    const form = ref({
      oldPasswd: '',
      newPasswd: '',
      reNewPasswd: ''
    });

    const showOldPassword = ref(false);
    const showNewPassword = ref(false);
    const showConfirmPassword = ref(false);
    const errorMessage = ref('');

    // 密码复杂度验证规则
    const oldPasswordRules = [
      { required: true, message: 'Send your old password', trigger: 'blur' }
    ];

    const newPasswordRules = [
      { required: true, message: 'Send your new password', trigger: 'blur' },
      { min: 6, message: 'Password length cannot be less than 6 digits.', trigger: 'blur' },
      { pattern: /[A-Za-z]/, message: 'Passwords must contain letters.', trigger: 'blur' },
      { pattern: /\d/, message: 'Password must contain numbers.', trigger: 'blur' }
    ];

    const confirmPasswordRules = [
      { required: true, message: 'comfirm password', trigger: 'blur' },
      { validator: validateConfirmPassword, trigger: 'blur' }
    ];

    // 校验新密码和确认密码是否一致
    function validateConfirmPassword(rule, value, callback) {
      if (value !== form.value.newPasswd) {
        callback(new Error('The new password entered twice is different.'));
      } else {
        callback();
      }
    }

    const handleBlur = (field) => {
      if (field === 'oldPasswd' && !form.value.oldPasswd) {
        errorMessage.value = 'Send your old password';
      } else if (field === 'newPasswd' && form.value.newPasswd.length < 6) {
        errorMessage.value = 'Password length cannot be less than 6 digits.';
      } else if (field === 'reNewPasswd' && form.value.reNewPasswd !== form.value.newPasswd) {
        errorMessage.value = 'The new password entered twice is different.';
      } else {
        errorMessage.value = '';
      }
    };

    const handleSubmit = async () => {
      // 提交前验证
      try {
        await formRef.value.validate();
        // 这里可以进行进一步的密码修改操作
        console.log('Password changed successfully.', form.value);
      } catch (error) {
        console.log('Form validation failed.');
      }
    };

    return {
      form,
      showOldPassword,
      showNewPassword,
      showConfirmPassword,
      errorMessage,
      oldPasswordRules,
      newPasswordRules,
      confirmPasswordRules,
      handleSubmit,
      handleBlur
    };
  }
};
</script>

<style scoped>
/* 你可以根据需求定制样式 */
#error-message {
  font-size: 14px;
  color: red;
  margin-top: 10px;
}
</style>
