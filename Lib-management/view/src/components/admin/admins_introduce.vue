<template>
  <div class="scrolling-container">
    <!-- 左箭头按钮 -->
    <button class="scroll-button left" @click="scrollLeft">←</button>

    <div class="scrolling-wrapper" ref="scrollWrapper">
      <div v-for="(section, index) in sections" :key="index" class="section">
        <el-card class="card">
          <template #header>
            <span class="card-title">{{ section.title }}</span>
          </template>
          <div class="text item">
            <p v-for="(item, idx) in section.content" :key="idx">{{ item }}</p>
          </div>
        </el-card>
      </div>
    </div>

    <!-- 右箭头按钮 -->
    <button class="scroll-button right" @click="scrollRight">→</button>
  </div>
</template>




<script lang="ts" setup>
import { ref } from 'vue'

const sections = ref([
  {
    title: 'Book Management',
    content: [
      'Book List: Display all books, can perform operations such as search, modify, delete',
      'Book Add: Add new books'
    ]
  },
  {
    title: 'Lending Management',
    content: ['Lend List: Display all lend records, can perform operations such as modify, delete']
  },
  {
    title: 'Password Management',
    content: ['Admins can modify their passwords here']
  },
  {
    title: 'Username Management',
    content: ["Show user's name when they successfully login"]
  }
])

const scrollWrapper = ref<HTMLElement | null>(null)

const scrollLeft = () => {
  if (scrollWrapper.value) {
    const scrollWrapperEl = scrollWrapper.value
    const width = scrollWrapperEl.offsetWidth
    const currentScrollPosition = scrollWrapperEl.scrollLeft

    // 判断是否已经在第一个板块
    if (currentScrollPosition === 0) {
      // 如果已经在第一个板块，跳转到最后一个板块
      scrollWrapperEl.scrollLeft = scrollWrapperEl.scrollWidth - width
    } else {
      // 向左滚动
      scrollWrapperEl.scrollLeft -= width
    }
  }
}

const scrollRight = () => {
  if (scrollWrapper.value) {
    const scrollWrapperEl = scrollWrapper.value
    const width = scrollWrapperEl.offsetWidth
    const currentScrollPosition = scrollWrapperEl.scrollLeft
    const maxScrollPosition = scrollWrapperEl.scrollWidth - width

    // 判断是否已经在最后一个板块
    if (currentScrollPosition >= maxScrollPosition) {
      // 如果已经在最后一个板块，跳转到第一个板块
      scrollWrapperEl.scrollLeft = 0
    } else {
      // 向右滚动
      scrollWrapperEl.scrollLeft += width
    }
  }
}
</script>



<style scoped>


.scrolling-container {
  position: relative;
  width: 100%;
  height: 80vh; /* 增加容器高度 */
  overflow: hidden;
  display: flex;
  justify-content: space-between;
  align-items: center;
}


.scrolling-wrapper {
  display: flex;
  transition: transform 0.3s ease; /* Smooth scrolling transition */
  overflow-x: scroll; /* Ensure horizontal scrolling is enabled */
  scroll-snap-type: x mandatory; /* 强制水平对齐 */
}

.section {
  min-width: 100%; /* 确保每个板块占据整个视窗宽度 */
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 40px; /* 增加内边距 */
  scroll-snap-align: start; /* 设置为滚动停靠点 */
}

.card-title {
  color: #fff; /* 开始时为白色 */
  background: linear-gradient(135deg, #87CEEB, #4B0082); /* 更改为从浅蓝色 (#87CEEB) 到深紫色 (#4B0082) 的渐变 */
  font-weight: bold;
  font-size: 24px; /* 增大标题字体 */
  padding: 20px 30px;
  border-radius: 8px 8px 0 0;
  animation: textGlow 2s infinite alternate ease-in-out,
             textColorChange 2s infinite alternate ease-in-out;
}

@keyframes textGlow {
  from {
    text-shadow: 0 0 10px #87CEEB, 0 0 20px #87CEEB, 0 0 30px #87CEEB, 0 0 40px #87CEEB;
  }
  to {
    text-shadow: 0 0 20px #4B0082, 0 0 40px #4B0082, 0 0 60px #4B0082, 0 0 80px #4B0082;
  }
}



.card {
  width: 90%; /* 占据大部分宽度 */
  height: 90%; /* 占据大部分高度 */
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2); /* 更大的阴影效果 */
  border-radius: 16px; /* 更圆润的边角 */
  background-color: #f4f7fb;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  font-size: 18px; /* 增大卡片内文本字体 */
}

.card:hover {
  transform: translateY(-20px); /* 更大的悬停位移 */
  box-shadow: 0 16px 32px rgba(0, 0, 0, 0.3); /* 更大的悬停阴影 */
}

.el-card__header {
  background: none;
  border-bottom: none;
  padding: 20px; /* 增加内边距 */
}

.el-card__body {
  padding: 40px; /* 增加内边距 */
  background-color: #fff;
  border-radius: 0 0 16px 16px;
}

.text {
  text-align: center;
  line-height: 1.8; /* 调整行高 */
}

.item {
  margin-bottom: 20px; /* 增加段落间距 */
  font-size: 18px; /* 增大内容字体 */
  color: #333; /* 深色文字 */
}

/* Scroll buttons styling */
.scroll-button {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  color: #fff; /* 白色文字 */
  background: linear-gradient(135deg, #87CEEB, #4B0082); /* 从浅蓝色 (#87CEEB) 到深紫色 (#4B0082) 的渐变 */
  font-weight: bold;
  font-size: 24px; /* 更大的按钮字体 */
  padding: 16px 24px;
  border-radius: 50%; /* 圆形按钮 */
  cursor: pointer;
  z-index: 10;
  animation: textGlow 2s infinite alternate ease-in-out,
             textColorChange 2s infinite alternate ease-in-out;
  border: none; /* 移除默认边框 */
  transition: transform 0.1s; /* 添加过渡效果以提高用户体验 */
}



/* 如果你的按钮有激活状态，可以添加如下代码 */
.scroll-button:active {
  transform: scale(0.98);
}

/* 确保 @keyframes 规则已经定义过 */
@keyframes textGlow {
  from {
    text-shadow: 0 0 10px #87CEEB, 0 0 20px #87CEEB, 0 0 30px #87CEEB, 0 0 40px #87CEEB;
  }
  to {
    text-shadow: 0 0 20px #4B0082, 0 0 40px #4B0082, 0 0 60px #4B0082, 0 0 80px #4B0082;
  }
}


/* 调整左右按钮的位置 */
.scroll-button.left {
  left: 20px; /* 增加左右按钮的间距 */
}

.scroll-button.right {
  right: 20px; /* 增加左右按钮的间距 */
}
</style>
