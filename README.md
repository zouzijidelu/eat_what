# eat_what

饮食类应用项目，包含 Chisha 移动端 HTML 原型。

---

## Chisha HTML 页面结构分析

### 一、整体架构

面向移动端的「吃啥」饮食类应用，采用多页 HTML + Tailwind CSS 构建，风格统一，无额外框架依赖。

---

### 二、页面层级与导航关系

```
index.html (首页)
├── recipe-detail.html  ← 食谱推荐轮播
├── food-list.html      ← 食物推荐「更多」
│   └── food-items.html ← 二级分类（通过 ?c=莓果类 等参数）
│       └── food-detail.html
└── plan-list.html      ← 饮食计划「更多」
    └── plan-detail.html ← 计划详情（通过 ?p=轻盈控卡 等参数）
        └── recipe-detail.html
```

---

### 三、各页面结构概览

| 页面 | 功能 | 主要布局特点 |
|------|------|-------------|
| **index.html** | 首页 | 顶部品牌区 + 搜索 + 食谱轮播 + 食物 4 宫格 + 饮食计划列表 |
| **food-list.html** | 食物分类 | 左侧一级分类 Tab + 右侧二级分类网格 |
| **food-items.html** | 二级分类食物列表 | 顶部 + 搜索 + 左图右文列表 |
| **food-detail.html** | 食物详情 | 左图右文主信息 + 营养素 4 宫格 + 推荐吃法 + 相关菜谱 |
| **plan-list.html** | 饮食计划列表 | 左图右文卡片列表 |
| **plan-detail.html** | 计划详情 | 计划信息 + 天数选择器 + 早/午/晚餐安排 + 计划说明 |
| **recipe-detail.html** | 菜谱详情 | 基本信息 + 营养素 + 食材清单 + 制作步骤 |

---

### 四、通用布局模式

**1. 外层容器**

```html
<body class="min-h-dvh bg-gradient-to-b from-rose-50 via-white to-white">
  <div class="mx-auto max-w-md px-4 pb-10 pt-4">
    <!-- 内容 -->
  </div>
</body>
```

- `max-w-md`：控制最大宽度
- `min-h-dvh`：占满视口高度
- 背景为浅玫红到白的渐变

**2. 顶部 Header 模式**

- 返回按钮：圆形 `<a>`，文字 `‹`
- 标题：`h1` 或 `h2`
- 右侧：部分页面有「首页」或「更多」链接

**3. 卡片样式**

- `rounded-[28px]`：大圆角
- `ring-1 ring-rose-100/70`
- `shadow-card` 或 `shadow-sm`

**4. 常见内容布局**

| 用途 | 布局 | 典型用法 |
|------|------|---------|
| 左图右文 | `flex gap-3`，左图 16×16～24×24 | 计划卡片、食物/食谱详情 |
| 上图下文 | `aspect-square` + 下方文字 | 食物推荐 4 宫格 |
| 4 宫格 | `grid grid-cols-4 gap-2` | 营养素、食物推荐 |
| 轮播 | `snap-x-mandatory` + `overflow-x-auto` | 食谱推荐 |

---

### 五、设计体系

**Tailwind 扩展色**

```javascript
brand: { 50, 100, 500, 600 }  // 主色
ink: "#1f2430"                // 主文字色
```

**常用自定义类**

- `soft-ring`：品牌色内阴影
- `clamp-2` / `clamp-3`：多行截断
- `no-scrollbar`：隐藏滚动条

---

### 六、交互与脚本

- **index.html**：食谱轮播（scroll-snap + 4.5s 自动切换 + 指示点）
- **food-list.html**：一级分类切换 + 二级分类动态渲染
- **food-items.html**：搜索过滤
- **plan-detail.html**：天数选择 + 早/午/晚餐内容切换

---

### 七、数据与资源

- 使用内联 JS 和静态 JSON 数据
- 图片为 `placehold.co` 占位图
- 详情页可通过 URL 参数（如 `?c=`、`?p=`）区分不同内容

---

### 八、小结

整体是一套面向移动端、以饮食为核心的静态原型，结构清晰，风格统一（玫红主色、大圆角、轻量卡片），可在此基础上接入真实数据和后端 API。
