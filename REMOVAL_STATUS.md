# Ya cap 功能移除进度

## 已完成 ✅

### 1. 合并图片功能
- ✅ 删除 capcap/ImageMerge/ 目录
- ✅ 移除 StatusBarController 中的菜单项和回调
- ✅ 移除 AppDelegate 中的相关处理方法
- ✅ 移除快捷键注册（handleImageMergeMenuTrigger, handleImageMergeShortcutTrigger）
- ✅ 移除 continueEditingMergedImage 方法

### 2. 上传文件/图床功能
- ✅ 删除 capcap/Upload/ 目录
- ✅ 移除 StatusBarController 中的菜单项和回调
- ✅ 移除 AppDelegate 中的相关处理方法
- ✅ 移除快捷键注册（handleFileUploadTrigger）
- ✅ 移除文件上传相关属性（fileUploadWindowController, fileUploadOpenPanel）
- ✅ 移除上传对话框方法（showFileUploadOpenPanel, showFileUploadDialog）

### 3. 剪贴板文本历史
- ✅ 移除 clipboardTextHistoryMonitor 属性
- ✅ 移除启动监控的代码

### 4. README 文件
- ✅ 删除多语言 README（en, fr, ja, ko, ru, vi, zh-TW）
- ✅ 只保留 README.md 和 README.zh-CN.md

## 待完成 ⏳

### 1. 美化预设样式
- ⏳ 需要修改 capcap/Editor/BeautifyPreset.swift
- ⏳ 简化为只保留基础圆角+阴影功能

### 2. 历史面板快速搜索
- ⏳ 需要修改 capcap/Capture/HistorySearch.swift
- ⏳ 简化历史面板界面

### 3. 设置面板清理
- ⏳ 移除上传相关设置页面
- ⏳ 移除剪贴板文本历史相关设置

### 4. 本地化字符串清理
- ⏳ 移除相关的本地化字符串

### 5. 构建验证
- ⏳ 验证代码能否正常编译
- ⏳ 修复编译错误
- ⏳ 测试核心功能
