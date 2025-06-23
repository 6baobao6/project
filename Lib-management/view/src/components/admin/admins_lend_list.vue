<template>
  <div>
    <!-- Header部分 -->
    <div id="header" ref="header"></div>

    <!-- 提示信息 -->
    <el-alert
      v-if="successMessage"
      title="Success"
      type="success"
      :closable="false"
      class="mb-4"
    >
      {{ successMessage }}
    </el-alert>

    <el-alert
      v-if="errorMessage"
      title="Error"
      type="error"
      :closable="false"
      class="mb-4"
    >
      {{ errorMessage }}
    </el-alert>

    <!-- 借还日志表格 -->
    <el-card>
      <div slot="header">
        <span>All Borrowed Books</span>
      </div>
      <el-table :data="loanLogs" style="width: 800px" stripe>
        <el-table-column label="Book ID" prop="bookId" />
        <el-table-column label="Book Name" prop="bookname" />
        <el-table-column label="Borrower" prop="username" />
        <el-table-column label="Lend Date" prop="lendDate" />
        <el-table-column label="Promised Back Date" prop="returnDate" />
        <el-table-column label="Situation">
          <template #default="{ row }">

            <span v-if="!row.returnDate || isOverdue(row)">Overdue</span>
            <span v-else>Lending</span>
          </template>
        </el-table-column>
        <el-table-column label="Actions">
          <template #default="{ row }">
            <el-button type="text" size="small" @click="deleteRecord(row)">Delete</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue';
import { ElAlert, ElTable, ElTableColumn, ElCard, ElButton } from 'element-plus';
import dayjs from 'dayjs';  // 引入 dayjs 库
import axios from 'axios'
import 'element-plus/dist/index.css';

export default {
  name: 'LoanLog',
  setup() {
    // 数据状态
    const loanLogs = ref([]);

    const successMessage = ref('Data loaded successfully!');
    const errorMessage = ref('');

    // 判断是否超期
    const isOverdue = (log) => {
      const currentTime = dayjs();
      const lendDate = dayjs(log.returnDate);
      const loanPeriod = 0;
      return currentTime.diff(lendDate, 'day') > loanPeriod;
    };

    // 删除记录
    const deleteRecord = async (row) => {
      try {
        const response = await fetch(`http://localhost:5000/api/lend_list/${row.bookId}`, {
          method: 'DELETE'
        });

        if (response.ok) {
          // 刷新数据
          fetchLoanLogs();
          successMessage.value = 'Record deleted successfully!';
        } else {
          errorMessage.value = 'Failed to delete record';
        }
      } catch (error) {
        errorMessage.value = 'Failed to delete record: ' + error.message;
      }
    };

     // 从后端获取数据
     const fetchLoanLogs = async () => {
      try {
        const response = await fetch('http://localhost:5000/api/lend_list'); // 替换为你的后端 URL
        loanLogs.value =  await response.json();
        successMessage.value = 'Data loaded successfully!';
      } catch (error) {
        errorMessage.value = 'Failed to load data: ' + error.message;
      }
    };

    // 动态加载头部内容
    onMounted(() => {
      const header = document.querySelector('#header');
      if (header) {
        header.innerHTML = '<h1>All Borrowed Books</h1>';
      }
      // 调用获取数据的函数
      fetchLoanLogs();
    });

    return {
      loanLogs,
      successMessage,
      errorMessage,
      isOverdue,
      deleteRecord,
    };
  },
};
</script>

<style scoped>
#header {
  text-align: center;
  margin-bottom: 20px;
}

.el-alert {
  margin-bottom: 20px;
}

.el-button {
  margin-left: 10px;
}
</style>
