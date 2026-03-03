# Shark

## 项目简介

Shark 是一个基于 HarmonyOS 开发的移动应用项目,支持手机设备。该项目采用 HarmonyOS SDK 6.0.2(22) 开发,兼容 SDK 5.0.0(12)。

## 项目信息

- **应用包名**: com.xiaobingkj.shark
- **版本号**: 1.0.0 (versionCode: 1000000)
- **目标设备**: 手机 (Phone)
- **开发框架**: HarmonyOS
- **目标SDK版本**: 6.0.2(22)
- **兼容SDK版本**: 5.0.0(12)

## 项目结构

```
Shark/
├── AppScope/              # 应用全局配置
│   ├── app.json5         # 应用配置文件
│   └── resources/        # 应用资源文件
├── entry/                 # 主入口模块
│   ├── src/
│   │   ├── main/         # 主要源码
│   │   │   ├── ets/      # ArkTS源码
│   │   │   │   ├── common/           # 公共组件
│   │   │   │   ├── entryability/     # 应用入口能力
│   │   │   │   ├── entrybackupability/ # 备份能力
│   │   │   │   ├── log/              # 日志模块
│   │   │   │   └── pages/            # 页面文件
│   │   │   │       ├── Index.ets              # 主页
│   │   │   │       ├── AboutView.ets          # 关于页面
│   │   │   │       ├── AddServerView.ets      # 添加服务器页面
│   │   │   │       ├── HistoryView.ets        # 历史记录页面
│   │   │   │       ├── MyAppView.ets          # 我的应用页面
│   │   │   │       ├── ServerListView.ets     # 服务器列表页面
│   │   │   │       ├── ServerView.ets         # 服务器详情页面
│   │   │   │       ├── SettingView.ets        # 设置页面
│   │   │   │       ├── SoundView.ets          # 音频页面
│   │   │   │       └── TabPage.ets            # 标签页面
│   │   │   └── resources/    # 资源文件
│   │   └── ohosTest/       # 测试代码
│   └── module.json5        # 模块配置
├── common/                # 公共模块
│   ├── BuildProfile.ets   # 构建配置
│   ├── LoadingMore.ets    # 加载更多组件
│   ├── NoMore.ets         # 没有更多数据组件
│   ├── TextAvatar.ets     # 文本头像组件
│   ├── Toast.ets          # Toast提示组件
│   ├── TopNavigationView.ets # 顶部导航视图
│   └── VideoComponent.ets # 视频组件
├── hvigor/                # 构建工具配置
├── oh_modules/            # 依赖模块
├── Upload_Management_API/ # 上传管理API
├── build-profile.json5    # 构建配置文件
├── oh-package.json5       # 项目依赖配置
└── hvigorfile.ts          # Hvigor构建脚本

```

## 主要功能模块

### 页面模块 (Pages)
- **Index**: 应用主页
- **AboutView**: 关于页面
- **AddServerView**: 添加服务器配置
- **HistoryView**: 历史记录查看
- **MyAppView**: 我的应用管理
- **ServerListView**: 服务器列表
- **ServerView**: 服务器详情与操作
- **SettingView**: 应用设置
- **SoundView**: 音频相关功能
- **TabPage**: 标签页导航

### 公共组件 (Common)
- **LoadingMore**: 加载更多组件
- **NoMore**: 无更多数据提示
- **TextAvatar**: 文本头像显示
- **Toast**: 消息提示组件
- **TopNavigationView**: 顶部导航栏
- **VideoComponent**: 视频播放组件

## 技术特性

### 核心能力
- **EntryAbility**: 应用主入口能力
- **EntryBackupAbility**: 数据备份能力
- **Push Kit**: 集成华为推送服务 (com.huawei.service.push.base_service)

### 权限要求
- `ohos.permission.INTERNET`: 网络访问权限

### 构建配置
- **构建模式**: Debug / Release
- **签名配置**: 支持 HarmonyOS 签名
- **严格模式**: 启用大小写敏感检查和规范化OHM URL

## 开发环境

### 前置要求
- DevEco Studio
- HarmonyOS SDK 5.0.0(12) 或更高版本
- Node.js (推荐 LTS 版本)

### 依赖管理
项目使用 Ohpm (OpenHarmony Package Manager) 进行依赖管理。

主要开发依赖:
- `@ohos/hypium`: 1.0.25 (测试框架)
- `@ohos/hamock`: 1.0.0 (Mock框架)

## 构建与运行

### 构建项目
```bash
# 使用 Hvigor 构建工具
hvigorw assembleHap
```

### 运行项目
1. 在 DevEco Studio 中打开项目
2. 连接 HarmonyOS 设备或启动模拟器
3. 点击运行按钮或使用快捷键运行应用

### 构建模式
- **Debug模式**: 用于开发和调试
- **Release模式**: 用于正式发布

## 签名配置

项目包含两种签名配置:
1. **default**: 默认签名配置,用于发布版本
2. **device**: 设备调试签名配置

签名文件:
- `dis.cer`: 证书文件
- `dis.p12`: 密钥库文件
- `disRelease.p7b`: 发布配置文件

## 项目特点

1. **模块化设计**: 采用 HarmonyOS 模块化架构,分离 entry 和 common 模块
2. **组件化开发**: 提供可复用的 UI 组件库
3. **推送服务**: 集成华为 Push Kit 服务
4. **数据备份**: 支持应用数据备份与恢复
5. **网络功能**: 具备完整的网络访问能力

## 版本历史

### v1.0.0 (当前版本)
- 初始版本发布
- 实现基础功能模块
- 集成推送服务
- 完成核心页面开发

## 开发团队

- **开发者**: xiaobingkj
- **组织**: example

## 许可证

本项目遵循相关开源协议,具体请查看 LICENSE 文件。

## 联系方式

如有问题或建议,请通过以下方式联系:
- 项目地址: [项目仓库链接]
- 问题反馈: [Issues链接]

---

**注意**: 本项目为 HarmonyOS 应用,需要在 HarmonyOS 环境下运行和开发。
