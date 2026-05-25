# BookScaner

一个基于 iOS 的图书扫码入库小工具，支持扫描 ISBN 条形码获取图书信息、保存到云端并导出 Excel。

## 功能概览

- 📷 **扫码识别**：使用相机扫描 EAN13/EAN8/Code128/Code39/Code93 条形码。
- 🖼️ **相册识别**：可从相册读取二维码/条码信息。
- 📚 **图书信息查询**：根据 ISBN 请求豆瓣图书接口并解析书名、作者、价格、简介、封面等信息。
- ☁️ **云端存储**：将图书信息保存到 LeanCloud（`BookInfo` 表）。
- 📋 **列表管理**：查看已入库图书、点击复制书名、清空全部记录。
- 📤 **Excel 导出**：导出 `export.xls` 并通过系统分享菜单发送。

## 技术栈

- **语言/框架**：Swift + UIKit + Storyboard
- **扫码能力**：AVFoundation
- **网络请求**：Alamofire
- **XML 解析**：SwiftyXMLParser
- **云端数据库**：AVOSCloud（LeanCloud SDK）
- **依赖管理**：CocoaPods

## 项目结构

```text
BookScaner/
├─ AppDelegate.swift         # 应用启动与 LeanCloud 初始化
├─ ViewController.swift      # 扫码入口（相机/相册）
├─ ResultVC.swift            # ISBN 查询结果页 + 添加入库
├─ BookListVC.swift          # 图书列表页 + 导出/清空
├─ Excel.swift               # Excel 导出逻辑
├─ ImageHelper.swift         # 图片工具
├─ ImageVIewExtension.swift  # UIImageView 网络图扩展
└─ SwiftNotice.swift         # 轻提示相关
```

## 快速开始

### 1) 环境要求

- Xcode（建议使用较新的稳定版）
- CocoaPods
- iOS 真机（扫码功能依赖相机，建议真机调试）

### 2) 安装依赖

在项目根目录执行：

```bash
pod install
```

安装完成后，请使用 `BookScaner.xcworkspace` 打开工程。

### 3) 配置 LeanCloud

当前项目在 `AppDelegate.swift` 中通过以下方式初始化 LeanCloud：

```swift
AVOSCloud.setApplicationId("<Your-App-Id>", clientKey: "<Your-Client-Key>")
```

请替换为你自己的 AppId / ClientKey 后再运行。

### 4) 运行

- 选择 iOS 设备并运行。
- 首次使用请在系统中授予相机权限。

## 使用说明

1. 打开应用进入扫码页。
2. 通过相机扫描图书 ISBN 条形码，或点击右上角“输入”从相册识别。
3. 在结果页确认图书信息，点击“添加”写入云端。
4. 进入书单页查看数据，可清空记录或导出 `export.xls`。

## 已知问题与维护建议

> 该项目为早期实现，维护时建议优先关注以下事项：

- 使用的是豆瓣 HTTP + XML 接口，可能存在稳定性与可用性风险。
- `Info.plist` 放开了 ATS（`NSAllowsArbitraryLoads = true`），安全策略较宽。
- 代码中存在较多强制解包（`!`），异常输入下可能导致崩溃。
- LeanCloud 凭据写在客户端代码中，不利于密钥轮换与安全管理。

## 许可证

当前仓库未包含明确 LICENSE 文件；如需开源发布，建议补充许可证声明。
