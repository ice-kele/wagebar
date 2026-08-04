# 贡献指南

感谢你对 WageBar 的兴趣！欢迎以任何方式参与贡献。

## 🚀 如何开始

1. **Fork** 本仓库
2. **Clone** 到本地：`git clone https://github.com/<你的用户名>/wagebar.git`
3. **安装 Flutter**：[flutter.dev/docs/get-started](https://flutter.dev/docs/get-started)
4. **安装依赖**：`cd app && flutter pub get`
5. **运行项目**：`flutter run`

## 📋 贡献流程

1. 在 [Issues](../../issues) 中找到你想解决的问题，或创建新 Issue 描述你要做的功能
2. 创建分支：`git checkout -b feat/你的功能名`
3. 编写代码，确保通过测试：
   ```bash
   cd app
   flutter analyze    # 静态分析无 error
   flutter test       # 所有测试通过
   ```
4. 提交代码（中文 commit message）：
   ```
   feat: 添加薪资配置页面
   fix: 修复加班费倍率计算错误
   docs: 更新 README
   ```
5. 创建 Pull Request，描述你的改动

## 📝 代码规范

### Dart 代码
- 遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart) 风格指南
- 使用 `flutter analyze` 确保无 warning
- 公共 API 添加文档注释 `///`

### 架构约定
- **数据模型** 放 `data/models/`
- **业务逻辑** 放 `domain/`
- **UI 页面** 放 `features/`
- **共享组件** 放 `shared/`
- 核心计算逻辑（如薪资计算）必须是**纯函数**，方便测试

### Commit 约定
- `feat:` 新功能
- `fix:` 修复 bug
- `docs:` 文档变更
- `refactor:` 重构（不改功能）
- `test:` 测试相关
- `chore:` 构建/工具变更

## 🎯 特别需要的帮助

- 🎨 **UI/UX 设计**：图标设计、配色方案、动画效果
- 🌍 **国际化**：英文翻译、其他语言
- 🧪 **测试**：各平台编译验证、边界用例测试
- 📱 **iOS 开发**：需要 macOS 环境的 CI 构建
- 📆 **节假日数据**：维护法定节假日/调休日历表

## 💬 交流

- Issue：用于 bug 报告和功能建议
- Discussions：用于一般讨论和问答

## ⚖️ 协议

提交的代码将遵循 [AGPL-3.0](LICENSE) 协议。
