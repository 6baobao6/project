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
      <el-table :data="books" style="width: 100%" align="center" @row-click="viewDetails">
        <el-table-column prop="name" label="Name" width="150"></el-table-column>
        <el-table-column prop="author" label="Author" width="150"></el-table-column>
        <el-table-column prop="publish" label="Publish" width="150"></el-table-column>
        <el-table-column prop="isbn" label="ISBN" width="150"></el-table-column>
        <el-table-column prop="price" label="Price" width="100"></el-table-column>
        <el-table-column prop="number" label="Number" width="120"></el-table-column>
        <el-table-column label="operate" width="200">
          <template #default="{ row }">
            <el-button @click="editBook(row)" size="mini" type="info">Edit</el-button>
            <el-button @click="deleteBook(row)" size="mini" type="danger">Delete</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 图书详情弹出框 -->
      <el-dialog title="Detail" :visible.sync="dialogVisible">
        <el-form label-width="100px">
          <el-form-item label="Name">
            <el-input v-model="selectedBook.name" disabled></el-input>
          </el-form-item>
          <el-form-item label="Author">
            <el-input v-model="selectedBook.author" disabled></el-input>
          </el-form-item>
          <el-form-item label="Publish">
            <el-input v-model="selectedBook.publish" disabled></el-input>
          </el-form-item>
          <el-form-item label="ISBN">
            <el-input v-model="selectedBook.isbn" disabled></el-input>
          </el-form-item>
          <el-form-item label="Price">
            <el-input v-model="selectedBook.price" disabled></el-input>
          </el-form-item>
          <el-form-item label="Number">
            <el-input v-model="selectedBook.number" disabled></el-input>
          </el-form-item>
        </el-form>
      </el-dialog>
    </el-main>
  </el-container>
</template>

<script>
import { ref, onMounted, computed} from 'vue';
import { ElTable, ElTableColumn, ElInput, ElButton, ElDialog, ElForm, ElFormItem, ElContainer, ElHeader, ElMain, ElRow, ElCol } from 'element-plus';

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
    ElCol
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

    // 模拟获取图书数据
    const fetchBooks = async () => {
    const response = await fetch('http://localhost:5000/api/books');
    books.value = await response.json();
  };

    // 搜索图书
    const searchBooks = () => {
      // 这里可以根据关键字过滤图书
      //fetchBooks(); // 这里只是模拟刷新
    };

    // 查看图书详情
    const viewDetails = (row) => {
      selectedBook.value = { ...row }; // 复制图书信息
      dialogVisible.value = true; // 打开弹出框
    };

    // 编辑图书
    const editBook = async (row) => {
    const updatedBook = { ...row };

    // 假设您会弹出一个输入框来获得书籍的更新信息
    const number = prompt("Edit Number:", updatedBook.number);
    if (number) updatedBook.number = number; // 更新书名作为示例

    const response = await fetch(`http://localhost:5000/api/books/${row.bookId}`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(updatedBook)
    });

    if (response.ok) {
        fetchBooks(); // 刷新图书列表
    } else {
        alert('Failed to update book');
    }
};

    // 删除图书
    const deleteBook = async (row) => {
  // 弹出确认对话框
      const confirmDelete = confirm('Are you sure you want to delete this book?');
      if (confirmDelete) {
        const response = await fetch(`http://localhost:5000/api/books/${row.bookId}`, {
            method: 'DELETE'
        });

        if (response.ok) {
            fetchBooks(); // 刷新图书列表
        } else {
            alert('Failed to delete book');
        }
      }
};
    // 页面加载时获取图书数据
    onMounted(() => {
      fetchBooks();
    });

    return {
      searchWord,
      books: filteredBooks,
      dialogVisible,
      selectedBook,
      searchBooks,
      viewDetails,
      editBook,
      deleteBook
    };
  }
};
</script>

<style scoped>
.input-search {
  width: 300px;
}

.el-header {
  padding: 20px 0; /* 增加顶部和底部的内边距 */
}

.el-main {
  padding-top: 20px; /* 增加顶部的内边距 */
}
</style>
