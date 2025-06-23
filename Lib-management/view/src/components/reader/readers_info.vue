<template>
  <div class="reader-info">
    <!-- 显示操作结果的提示框 -->
    <el-alert
      v-if="message"
      :type="messageType"
      :title="message"
      show-icon
      closable
      @close="message = ''"
    />

    <el-card class="reader-card" shadow="always">
      <div slot="header" class="clearfix">
        <span>My info</span>
        <el-button @click="editMode = !editMode" :type="editMode ? 'danger' : 'primary'" class="edit-btn" size="mini">
          {{ editMode ? 'cancel' : 'edit' }}
        </el-button>
      </div>

      <el-form :model="readerInfo" v-if="!editMode" label-width="120px">
        <el-form-item label="ID">
          <span>{{ readerInfo.readerId }}</span>
        </el-form-item>
        <el-form-item label="Name">
          <span>{{ readerInfo.name }}</span>
        </el-form-item>
        <el-form-item label="Sex">
          <span>{{ readerInfo.sex }}</span>
        </el-form-item>
        <el-form-item label="Birth">
          <span>{{ readerInfo.birth }}</span>
        </el-form-item>
        <el-form-item label="Address">
          <span>{{ readerInfo.address }}</span>
        </el-form-item>
        <el-form-item label="Phone">
          <span>{{ readerInfo.phone }}</span>
        </el-form-item>
      </el-form>

      <!-- 编辑模式下显示表单 -->
      <el-form v-else :model="readerInfo" label-width="120px">
        <el-form-item label="ID">
          <el-input v-model="readerInfo.readerId" disabled></el-input>
        </el-form-item>
        <el-form-item label="Name">
          <el-input v-model="readerInfo.name" placeholder="Please send your name"></el-input>
        </el-form-item>
        <el-form-item label="Sex">
          <el-select v-model="readerInfo.sex" placeholder="Choose your sex">
            <el-option label="Male" value="Male"></el-option>
            <el-option label="Female" value="Female"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="Birth">
          <el-date-picker v-model="readerInfo.birth" type="date" placeholder="Choose your birth"></el-date-picker>
        </el-form-item>
        <el-form-item label="Address">
          <el-input v-model="readerInfo.address" placeholder="Please send your address"></el-input>
        </el-form-item>
        <el-form-item label="Phone">
          <el-input v-model="readerInfo.phone" placeholder="Please send your phone number"></el-input>
        </el-form-item>
      </el-form>

      <div class="action-buttons" v-if="editMode">
        <el-button type="primary" @click="updateInfo">Save</el-button>
      </div>
    </el-card>
  </div>
</template>

<script>
import { ref } from 'vue';
import { ElCard, ElForm, ElFormItem, ElInput, ElSelect, ElOption, ElButton, ElDatePicker, ElAlert } from 'element-plus';

export default {
  name: 'ReaderInfo',
  components: {
    ElCard, ElForm, ElFormItem, ElInput, ElSelect, ElOption, ElButton, ElDatePicker, ElAlert
  },
  setup() {
    const editMode = ref(false);  // 是否处于编辑模式
    const message = ref('');      // 操作信息提示
    const messageType = ref('success'); // 提示框类型（成功/失败）

    // 用户个人信息（模拟数据）
    const readerInfo = ref({
      readerId: '123456',
      name: 'kzy',
      sex: '男',
      birth: '1990-01-01',
      address: '北京市朝阳区',
      phone: '12345678901'
    });

    // 更新信息
    const updateInfo = () => {
      // 模拟保存数据的操作
      // 这里可以替换为实际的 API 调用
      message.value = '个人信息已更新成功！';
      messageType.value = 'success';
      editMode.value = false;
    };

    // 取消编辑
    const cancelEdit = () => {
      // 取消编辑时恢复初始值
      message.value = '编辑已取消。';
      messageType.value = 'warning';
      editMode.value = false;
    };

    return {
      readerInfo,
      editMode,
      message,
      messageType,
      updateInfo,
      cancelEdit
    };
  }
};
</script>

<style scoped>
.reader-info {
  max-width: 600px;
  margin: 0 auto;
}

.reader-card {
  margin-top: 20px;
}

.edit-btn {
  float: right;
}

.action-buttons {
  margin-top: 20px;
  display: flex;
  justify-content: space-between;
}

.el-alert {
  margin-bottom: 20px;
}
</style>
