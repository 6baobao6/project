<template>
  <div>
    <div id="header" ref="header"></div>

    <el-alert
      v-if="errorMessage"
      title="Error"
      type="error"
      :closable="false"
      class="mb-4"
    >
      {{ errorMessage }}
    </el-alert>

    <el-card>
      <div slot="header">
        <span>My lend list</span>
      </div>
      <el-table :data="loanLogs" style="width: 800px" stripe>
        <el-table-column label="Book ID" prop="bookId" />
        <el-table-column label="Book Name" prop="bookname" />
        <el-table-column label="Lend Date" prop="lendDate" />
        <el-table-column label="Promised Return Date" prop="returnDate" />
        <el-table-column label="Situation">
          <template #default="{ row }">

            <span v-if=" isOverdue(row)">Overdue</span>
            <span v-else>Lending</span>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue';
import { ElAlert, ElTable, ElTableColumn, ElCard } from 'element-plus';
import 'element-plus/dist/index.css';
import dayjs from 'dayjs';  // 引入 dayjs 库
import axios from 'axios';
import router from '@/router';


const username = ref('');  // State for storing the username
const token = localStorage.getItem('jwt');  // Make sure to set token after login


export default {
  name: 'LoanLog',
  setup() {
    const loanLogs = ref([]);
    const errorMessage = ref('');

     // 判断是否超期
     const isOverdue = (log) => {
      const currentTime = dayjs();
      const lendDate = dayjs(log.returnDate);
      const loanPeriod = 0; // 假设借期为30天
      return currentTime.diff(lendDate, 'day') > loanPeriod;
    };






// Function to fetch username from the backend
const fetchUsername = async () => {
  if (!token) {
    console.error('No token found');
    return;
  }

  try {
    const response = await axios.get('http://localhost:5000/api/user/current_user', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    username.value = response.data.username;  // Set the username upon successful API call
  } catch (error) {
    console.error('Failed to fetch username:');
  }
};


// 加载借还日志
const loadLoanLogs = async () => {
  if (!username) {
    console.error('Username is required to fetch loan logs.');
    return;
  }

  try {
    const response = await fetch(`http://localhost:5000/api/user_lend_list?username=${username.value}`);
    console.log(response);
    if (!response.ok) {
      throw new Error('Network response was not ok');
    }
    const data = await response.json();
    loanLogs.value = data;  // Assuming loanLogs is a ref or reactive variable
  } catch (error) {
    console.error('Error fetching lend list:', error);
    errorMessage.value = 'Failed to load loan logs.';
  }
};

    // 动态加载头部内容
onMounted(async () => {
  const header = document.querySelector('#header');
  if (header) {
    header.innerHTML = '<h1>Lend Lists</h1>';
  }
  await fetchUsername();  // Fetch username when the component is mounted
  await loadLoanLogs();
});

return {
  loanLogs,
  isOverdue,
  errorMessage,
};
},
};
</script>

<style scoped>
#header {
  text-align: center;
  margin-bottom: 20px;
  background-color:rgba(255, 255, 255, 0.8);
}

.el-alert {
  margin-bottom: 20px;
}
</style>
