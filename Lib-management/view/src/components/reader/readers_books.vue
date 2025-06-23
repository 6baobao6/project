<template>
  <el-container>
    <!-- 页头 -->
    <el-header>
      <el-row type="flex" justify="space-between" align="middle">
        <el-col :span="6"><h2>All Books</h2></el-col>
        <el-col :span="12">
          <el-input
            placeholder="Send a book name"
            v-model="searchWord"
            clearable
            @input="searchBooks"
            class="input-search"
          />
        </el-col>
      </el-row>
    </el-header>
    <!-- 主体内容 -->
    <el-main>
      <el-table :data="books" style="width: 100%" @row-click="viewDetails">
        <el-table-column prop="name" label="Name" width="150"></el-table-column>
        <el-table-column prop="author" label="Author" width="150"></el-table-column>
        <el-table-column prop="publish" label="Publish" width="150"></el-table-column>
        <el-table-column prop="isbn" label="ISBN" width="150"></el-table-column>
        <el-table-column prop="price" label="Price" width="100"></el-table-column>
        <el-table-column prop="number" label="Number" width="120"></el-table-column>
        <!-- 新增lend按钮 -->
        <el-table-column label="Operations">
          <template #default="scope">
            <el-button type="primary" @click="showLendModal(scope.row)">Lend</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 图书详情弹出框 -->
      <el-dialog title="Detail" :visible.sync="dialogVisible">
        <el-form label-width="100px">
          <el-form-item label="Name">
            <el-input :value="selectedBook.name" disabled></el-input>
          </el-form-item>
          <el-form-item label="Author">
            <el-input :value="selectedBook.author" disabled></el-input>
          </el-form-item>
          <el-form-item label="Publish">
            <el-input :value="selectedBook.publish" disabled></el-input>
          </el-form-item>
          <el-form-item label="ISBN">
            <el-input :value="selectedBook.isbn" disabled></el-input>
          </el-form-item>
          <el-form-item label="Price">
            <el-input :value="selectedBook.price" disabled></el-input>
          </el-form-item>
          <el-form-item label="Number">
            <el-input :value="selectedBook.number" disabled></el-input>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="showLendModal(selectedBook)">Lend</el-button>
          </el-form-item>
        </el-form>
      </el-dialog>

      <!-- 借阅日期选择弹出框 -->
      <el-dialog title="Choose Return Date" v-model="lendModalVisible" width="500">
        <el-form label-width="100px">
          <el-form-item label="Return Date">
            <el-date-picker
              v-model="returnDate"
              type="date"
              placeholder="Pick a return date"
              @change="onDateSelected"
            />
          </el-form-item>
        </el-form>
        <span slot="footer" class="dialog-footer">
          <el-button @click="lendModalVisible = false">Cancel</el-button>
          <el-button type="primary" @click="confirmLend">Confirm</el-button>
        </span>
      </el-dialog>
    </el-main>
  </el-container>
</template>

<script>
import { ref, onMounted, computed} from 'vue';
import {
  ElTable,
  ElTableColumn,
  ElInput,
  ElButton,
  ElDialog,
  ElForm,
  ElFormItem,
  ElContainer,
  ElHeader,
  ElMain,
  ElRow,
  ElCol,
  ElDatePicker // 添加这一行以注册 ElDatePicker 组件
} from 'element-plus';
import axios from 'axios';
import dayjs from 'dayjs';  // 引入 dayjs 库

export default {
  name: 'BookManagement',
  components: {
    ElTable,
    ElTableColumn,
    ElInput,
    ElButton,
    ElDialog,
    ElForm,
    ElFormItem,
    ElContainer,
    ElHeader,
    ElMain,
    ElRow,
    ElCol,
    ElDatePicker // 注册 ElDatePicker 组件
  },
  setup() {
    const searchWord = ref('');
    const books = ref([]);
    const filteredBooks = computed(() => {
      if (!searchWord.value) return books.value;
      return books.value.filter(book =>
        book.name.toLowerCase().includes(searchWord.value.toLowerCase())
      );
    });
    const dialogVisible = ref(false);
    const selectedBook = ref({});
    const lendModalVisible = ref(false);
    const selectedBookForLend = ref(null);
    const returnDate = ref(null);
    const token = localStorage.getItem('jwt');  // Make sure to set token after login
    const username = ref('');  // State for storing the username

    const searchBooks = () => {
      // 这里可以根据关键字过滤图书
      //fetchBooks(); // 这里只是模拟刷新
    };


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


const fetchBooks = async () => {
    try {
      const response = await axios.get('http://localhost:5000/api/books');
      books.value = response.data;
    } catch (error) {
      console.error('Error fetching books:', error);
      alert('An error occurred while fetching the books.');
    }
};

const updateSearchWord = (event) => {
      searchWord.value = event.target.value;
};

const viewDetails = (row) => {
      selectedBook.value = { ...row };
      dialogVisible.value = true;
};

const showLendModal = async (book) => {
  try {
    const response = await axios.get(`http://localhost:5000/api/check-lend-status?bookId=${book.bookId}`);

    if (response.data.isLent)  {
      alert('The book is already lent and not returned yet.');
      return;
    }

    // 如果没有被借出，设置选中的书籍并显示日期选择器
    selectedBookForLend.value = book;
    lendModalVisible.value = true;

  } catch (error) {
    console.error('Error checking lend status:', error);
    alert('An error occurred while checking the lend status of the book.');
  }
};

    const confirmLend = async () => {
  if (!selectedBookForLend.value || !returnDate.value) {
    alert('Please choose the date on which you promise to return the book.');
    return;
  }


  console.log(returnDate.value)

  // 获取当前日期作为借出日期并转换为 UTC 字符串格式
  const lendDate = new Date().toISOString().split('T')[0];

  // 将用户选择的还书日期转换为 UTC 字符串格式
  const returnDateUTC = new Date(returnDate.value.getTime() - returnDate.value.getTimezoneOffset() * 60000)
    .toISOString()
    .split('T')[0];

  console.log(returnDateUTC)

    // 检查还书日期是否早于借出日期
  if (returnDateUTC < lendDate) {
    alert('The return date cannot be earlier than the lend date.');
    return;
  }
  try {
    const response = await axios.post('http://localhost:5000/api/lend', {
      bookId: selectedBookForLend.value.bookId,
      bookname: selectedBookForLend.value.name,
      lendDate: lendDate,
      returnDate: returnDateUTC,
      username: username.value
    });
    console.log('Lend successful!');
    lendModalVisible.value = false; // 关闭借阅模态框
  } catch (error) {
    console.error('Error lending book:', error);
  }
};

    const onDateSelected = (date) => {
      console.log('Selected return date:', date);
    };




    onMounted(() => {
      fetchBooks();
      fetchUsername();  // Fetch username when the component is mounted
    });

    return {
      searchWord,
      searchBooks,
      books: filteredBooks,
      dialogVisible,
      selectedBook,
      updateSearchWord,
      viewDetails,
      lendModalVisible,
      selectedBookForLend,
      showLendModal,
      returnDate,
      onDateSelected,
      confirmLend
    };
  }
};
</script>

<style scoped>
.el-row{
  background-color:rgba(255, 255, 255, 0.8);
}
.input-search {
  width: 300px;
}

.el-header {
  padding: 30px 0; /* 增加顶部和底部的内边距 */
}

.el-main {
  padding-top: 30px; /* 增加顶部的内边距 */
}
</style>
