<h1 align="center">Ya cap</h1>

<p align="center">
  macOS 菜单栏截图工具：双击 <code>⌘</code> 截图，标注、长截图、录屏、文字识别和翻译都在同一个浮动编辑器里完成。
</p>

<p align="center">
  <a href="https://github.com/weiguhzy-oss/ya-cap/releases/latest"><img alt="Latest release" src="https://img.shields.io/github/v/release/weiguhzy-oss/ya-cap?style=flat-square"></a>
  <img alt="macOS 14+" src="https://img.shields.io/badge/macOS-14%2B-black?style=flat-square&logo=apple">
  <img alt="Swift 5.9" src="https://img.shields.io/badge/Swift-5.9-orange?style=flat-square&logo=swift">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square"></a>
</p>

<p align="center">
  <a href="https://github.com/weiguhzy-oss/ya-cap/releases/latest">下载最新版本</a> ·
  <a href="CHANGELOG.md">更新日志</a> ·
  <a href="https://github.com/weiguhzy-oss/ya-cap/issues">Issues</a>
</p>

Ya cap 常驻菜单栏，不占 Dock。双击 `⌘` 唤起选区，悬停窗口一点即贴边，拖拽选区按 Retina 原生分辨率输出。截完图不用切换应用——标注、长截图、美化、录屏、识别文字、翻译都在同一个浮动工具栏里。

纯 AppKit 实现，无 Electron、无第三方依赖、无遥测、无订阅。文字识别和翻译默认走 Apple 端上模型，不联网也能用。

macOS 14+ ・ 通用二进制（Apple Silicon + Intel）

## 主要功能

- **双击 `⌘` 触发。** 在任意应用中双击 `⌘` 即刻唤起；也可以在设置里录制自定义全局快捷键，另有独立的全屏截图快捷键。按住 `⌥` 再触发可启用 3–10 秒倒计时。
- **窗口贴边与像素级选区。** 悬停窗口自动识别边界，一点即截；或拖拽任意区域。多显示器全量支持。窗口截图可选圆角和 macOS 风格投影。
- **可二次编辑的标注。** 矩形、椭圆、直线、箭头、画笔、高亮笔、聚光灯、马赛克、橡皮擦、序号、文字、Emoji、插入图片。放下之后还能拖、能转、能改、能撤销。
- **长截图。** 在选区内滚动即连续捕获并实时拼接，合并后继续在同一个编辑器里编辑。
- **录屏。** 直接录制选区，输出 MP4 或 GIF，可录系统声音和麦克风，麦克风输入设备可选。
- **文字识别与翻译。** Apple Vision 端上识别图片文字，也可接入百度或腾讯云 OCR。翻译默认用 Apple 端上模型，无需任何配置；也可接入 DeepSeek 或任意 OpenAI 兼容接口。支持 16 种目标语言，源语言本地检测。
- **美化与钉图。** 渐变背景、桌面壁纸背景、圆角、阴影、内边距随手调；或把成图钉在所有窗口之上做对照。
- **二维码识别与取色器。** 一键识别截图里的二维码内容，或调用取色器复制 `#RRGGBB`。
- **文件名模板。** 用 `{date}`、`{time}`、`{rand:N}`、`{daily:N}`、`{width}x{height}` 组合命名规则，图片和录屏分别配置，内置若干预设。
- **工具栏自定义。** 拖拽调整主工具栏、侧边工具栏和隐藏工具的分布，并为每个工具录制编辑器内快捷键。

## 环境要求

- macOS 14.0+
- **屏幕录制权限**：截图和录屏所需，必须授予
- **辅助功能权限**：双击 `⌘` 全局触发所需，必须授予
- **麦克风权限**：可选，仅在录屏需要录人声时使用

首次启动会打开设置窗口并展示权限状态，授予后即可使用。

## 安装

从 [Releases](https://github.com/weiguhzy-oss/ya-cap/releases/latest) 下载 DMG，拖入「应用程序」即可。

如果 macOS 提示 `Apple 无法验证“Ya cap”是否包含恶意软件`，对你信任的应用包移除 quarantine 标记后再打开：

```bash
xattr -dr com.apple.quarantine "/Applications/Ya cap.app"
```

只对你信任的构建执行这个命令，例如本仓库的发布版本或你本地自行构建的版本。

## 使用方法

1. 双击 `⌘`，按下自定义快捷键，或从菜单栏选择「截图」。
2. 悬停窗口并点击可截取窗口；也可以拖拽选择任意区域。
3. 用浮动工具栏标注、长截图、录屏、识别文字、翻译、美化、保存或钉图。
4. 点击确认或按 `Enter` 把结果复制到剪贴板；按 `Esc` 取消。

## 编辑器工具

| 工具 | 作用 |
|------|------|
| 矩形 / 椭圆 | 绘制描边形状，可选颜色和线宽 |
| 直线 / 箭头 | 绘制直线或箭头，选中后可移动端点、弯曲箭头 |
| 画笔 | 绘制平滑的自由线条 |
| 高亮笔 | 绘制半透明高亮，重叠不会反复加深 |
| 聚光灯 | 压暗周围区域，突出指定范围 |
| 马赛克 | 在敏感区域刷出像素化遮挡，可调块大小 |
| 橡皮擦 | 擦除已有标注 |
| 序号 | 添加自动递增的序号圆点，放置时拖拽可带出引线 |
| 文字 / Emoji | 添加可编辑文字或 Emoji，支持颜色和字号 |
| 插入图片 | 把另一张图片叠加到当前截图上 |
| 取色器 | 选取屏幕任意颜色并复制 `#RRGGBB` |
| 放大镜 | 放置一个圆形放大镜，1–6 倍可调，可指定放大的源位置 |
| 旋转 | 左转或右转 90° |
| 长截图 | 在选区内滚动拼接，完成后继续编辑 |
| 美化 | 渐变或壁纸背景、圆角、阴影、内边距 |
| 二维码 | 识别截图中的二维码内容 |
| 文字识别 | 识别图片中的文字并复制 |
| 截图翻译 | 识别后翻译，支持 16 种目标语言 |
| 录制 | 录制当前选区为 MP4 或 GIF |
| 保存 / 钉图 / 确认 | 存为文件、置顶悬浮，或复制到剪贴板 |

选中标注后会显示对应的调整控件：形状、线条和文字支持旋转，箭头和序号引线支持弯曲，箭头端点可重新拖动，文字可再次编辑。

## 设置

设置窗口分十个面板：

| 面板 | 内容 |
|------|------|
| 通用 | 界面语言（简体中文 / 繁體中文 / English）、菜单栏图标、开机启动 |
| 快捷键 | 截图、复制到剪贴板、保存到文件、全屏截图四组快捷键 |
| 工具栏 | 拖拽调整工具分布，录制工具的编辑器内快捷键 |
| 截图与贴图 | 倒计时秒数、窗口截图阴影及尺寸 |
| 录制 | 输出格式、系统声音、麦克风及输入设备 |
| 文件与输出 | 截图和录屏的保存路径、是否询问位置、输出质量、文件名规则 |
| 文字识别 | OCR 服务商（Apple / 百度 / 腾讯云）及凭据 |
| 翻译 | 翻译服务商开关、密钥、模型和排序，顺序决定回退优先级 |
| 权限 | 辅助功能、屏幕录制、麦克风的状态和跳转入口 |
| 关于 | 版本信息、源码链接、更新检查 |

设置面板显示时会在 Dock 出现应用图标，关闭后移除。

## 文字识别与翻译

文字识别默认用 Apple Vision，完全在本机运行。也可以在设置里换成百度或腾讯云 OCR，需要填入对应的 API 凭据。

翻译默认启用 Apple 翻译，端上运行、无需配置，首次使用某个语种时系统可能会下载语言包。需要更强的翻译质量时，可以在翻译面板里启用 DeepSeek 或任意 OpenAI 兼容接口并填入密钥。启用多个服务商时，面板里的排序就是回退顺序。

源语言由本地检测，目标语言在翻译面板里选。如果识别出的文字已经是目标语言，方向会自动翻转成英语，避免同语种互译。

所有 API 密钥只保存在本机 `UserDefaults`，不会上传。

## 从源码构建

```bash
# 构建并打包为 build/Ya cap.app
bash scripts/bundle.sh

# 本地开发：重新构建、替换已安装版本、重启并确认运行
bash scripts/rebuild-and-open.sh

# 打包可拖拽安装的 DMG（通用二进制）
bash scripts/package-dmg.sh
```

应用包输出到 `build/Ya cap.app`，DMG 输出到 `dist/`。

## 项目结构

- `capcap/App/` — 应用入口、AppDelegate 和 bundle 元数据
- `capcap/Capture/` — 截图遮罩、选区、窗口检测、ScreenCaptureKit 捕获、长截图拼接、录屏、钉图
- `capcap/Editor/` — 标注模型、编辑画布、浮动工具栏、美化渲染、工具栏布局
- `capcap/Translation/` — 文字识别、翻译服务商和 OCR/翻译面板
- `capcap/Trigger/` — 双击 `⌘` 监听和全局快捷键注册
- `capcap/UI/` — 菜单栏控制器、toast、鼠标提示
- `capcap/Settings/` — 设置窗口和各偏好面板
- `capcap/Utilities/` — 默认值、本地化、文件名模板、更新检查
- `scripts/` — 编译检查、打包、重启运行、图标和 DMG 脚本

## 第三方许可证

- [PermissionFlow](https://github.com/jaywcjlove/PermissionFlow) 使用 MIT License，详见 [ThirdParty/PermissionFlow/LICENSE](ThirdParty/PermissionFlow/LICENSE)。

## License

[MIT](LICENSE)
