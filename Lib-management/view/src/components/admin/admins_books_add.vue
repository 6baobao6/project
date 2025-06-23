<template>
  <div class="add-book-form">
    <el-form ref="formRef" :model="formData" :rules="rules" label-width="100px" class="form-container">
      <el-form-item label="Name" prop="name">
        <el-input v-model="formData.name" placeholder="Please send book name"></el-input>
      </el-form-item>

      <el-form-item label="Author" prop="author">
        <el-input v-model="formData.author" placeholder="Please send author"></el-input>
      </el-form-item>

      <el-form-item label="Publish" prop="publish">
        <el-input v-model="formData.publish" placeholder="Please send publish"></el-input>
      </el-form-item>

      <el-form-item label="ISBN" prop="isbn">
        <el-input v-model="formData.isbn" placeholder="Please send ISBN"></el-input>
      </el-form-item>

      <el-form-item label="Price" prop="price">
        <el-input v-model="formData.price" placeholder="Please send price"></el-input>
      </el-form-item>

      <el-form-item label="Number" prop="number">
        <el-input v-model="formData.number" placeholder="Please send number"></el-input>
      </el-form-item>

      <el-form-item>
        <el-button type="primary" @click="submitForm">Add</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script>
import { ref } from 'vue';
import { ElForm, ElFormItem, ElInput, ElButton } from 'element-plus';
import axios from 'axios';

export default {
  components: {
    ElForm,
    ElFormItem,
    ElInput,
    ElButton,
  },
  setup() {
    // Form data model
    const formData = ref({
      name: '',
      author: '',
      publish: '',
      isbn: '',
      price: '',
      number: '',
    });

    // Custom validator for ISBN
    const validateISBN = (rule, value, callback) => {
      if (value) {
        // Check if the ISBN already exists in the books.json
        axios.get('http://localhost:5000/api/check-isbn', { params: { isbn: value } })
          .then(response => {
            if (response.data.exists) {
              callback(new Error('ISBN already exists'));
            } else {
              callback();
            }
          })
          .catch(error => {
            console.error('Error checking ISBN:', error);
            callback(new Error('Failed to check ISBN'));
          });
      } else {
        callback(new Error('Please send ISBN'));
      }
    };

    // Validation rules
    const rules = ref({
      name: [{ required: true, message: 'Please send book name', trigger: 'blur' }],
      author: [{ required: true, message: 'Please send author', trigger: 'blur' }],
      publish: [{ required: true, message: 'Please send publish', trigger: 'blur' }],
      isbn: [{ required: true, message: 'Please send ISBN', trigger: 'blur' },
      { validator: validateISBN, trigger: 'blur' }
      ],
      price: [{ required: true, message: 'Please send price', trigger: 'blur' }],
      number: [{ required: true, message: 'Please send number', trigger: 'blur' }],
    });

    // Form reference
    const formRef = ref(null);

    // Submit form handler
    const submitForm = async () => {
      try {
        // Validate the form
        await formRef.value.validate();

        // Send data to the backend
        const response = await axios.post('http://localhost:5000/api/books', formData.value);

        if (response.status === 201) {
          alert('Book added successfully.');
          // Clear the form after successful submission
          formData.value = {
            name: '',
            author: '',
            publish: '',
            isbn: '',
            price: '',
            number: '',
          };
        } else {
          alert('Failed to add book.');
        }
      } catch (error) {
        console.error('Form validation failed or request failed.', error);
        alert('Failed to add book.');
      }
    };

    return {
      formData,
      rules,
      submitForm,
      formRef,
    };
  },
};
</script>

<style scoped>
.add-book-form {
  margin-top: 20px;
  max-width: 800px;
  margin: 0 auto;
}
.form-container {
  padding: 20px;
  background-color: #f9f9f9;
  border-radius: 8px;
}
</style>
