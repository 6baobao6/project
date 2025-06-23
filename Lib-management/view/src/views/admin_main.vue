<template>
 <div class="admin_container">
  <div class="nav">
    <admins_header />
  </div>
  <div class="content">
     <RouterView></RouterView>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent } from 'vue';
import admins_header from '../components/admin/admins_header.vue';
import { RouterView } from 'vue-router';

export default defineComponent({
  name: 'UserPage',
  components: {
    admins_header,
  },
  data() {
    return {
      readerName: 'Reader Name',
    };
  },
  mounted() {
    // 你可以在这里进行其他初始化操作
  },
});
</script>

<style scoped>
.admin_container{
  position: absolute;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  width: 100%;
  background: url('..\assets\cool-background.png') no-repeat center center;
  background-size: cover;
  position: absolute;
}
.content {
  padding-top: 60px; /* 给导航栏留出空间 */
  display: flex; /* 启用flexbox布局 */
  justify-content: center; /* 水平居中 */
  align-items: center; /* 垂直居中 */
  min-height: 100vh; /* 确保内容区域至少填满视口 */
  text-align: center; /* 使文本水平居中 */
  width: 100%;
}

.nav {
  height: 60px; /* 导航栏高度 */
  display: flex; /* 使用flexbox布局 */
  align-items: center; /* 垂直居中 */
  justify-content: space-between;
  padding: 0 20px; /* 内边距 */
  position: fixed; /* 固定在页面顶部 */
  top: 0; /* 距离页面顶部为0 */
  width: 100%;
  z-index: 1000; /* 确保导航栏位于页面其他内容之上 */
}
</style>
