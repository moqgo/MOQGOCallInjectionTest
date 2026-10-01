# GitHub Actions 云编译教程（不用 Mac）

## 原理
GitHub 提供免费的 macOS 虚拟机，自动帮你编译 iOS App。你只需要把代码传到 GitHub，它自动编译出 IPA。

---

## 你需要准备

1. **GitHub 账号**（免费注册：https://github.com/signup）
2. **Apple ID**（你 iPhone 登录的那个）
3. **Windows 电脑**（用来操作 GitHub）

---

## 第一步：创建 GitHub 仓库

1. 打开 https://github.com/new
2. Repository name 填：`MOQGOCallInjectionTest`
3. 选 **Public**（公开，免费额度才够）
4. 勾选 **Add a README file**
5. 点 **Create repository**

---

## 第二步：上传代码

### 方法 A：网页上传（最简单）

1. 在你的仓库页面，点 **Add file** → **Upload files**
2. 把整个 `MOQGOCallInjectionTest` 文件夹里的所有文件拖进去
   - 包括 `.github` 文件夹（隐藏文件夹，要显示隐藏文件才能看到）
   - `MOQGOCallInjectionTest.xcodeproj` 文件夹
   - `MOQGOCallInjectionTest` 文件夹
   - 所有 `.md` 文件
3. 点 **Commit changes**

### 方法 B：Git 命令行（如果你会用）

```bash
cd MOQGOCallInjectionTest
git init
git add .
git commit -m "initial commit"
git remote add origin https://github.com/你的用户名/MOQGOCallInjectionTest.git
git branch -M main
git push -u origin main
```

---

## 第三步：触发编译

1. 在你的仓库页面，点顶部 **Actions** 标签
2. 如果看到提示"Workflows aren't being run on this repository yet"，点 **I understand my workflows, go ahead and enable them**
3. 左侧选 **iOS Build - MOQGOCallInjectionTest**
4. 点右上角 **Run workflow** 按钮
5. 选 **main** 分支，点 **Run workflow**
6. 等 5-10 分钟

---

## 第四步：下载 IPA

1. 编译完成后（绿色对勾），点进去
2. 拉到下面 **Artifacts** 区域
3. 下载 `MOQGOCallInjectionTest-unsigned-ipa`
4. 解压得到 `.ipa` 文件

---

## 第五步：装到 iPhone

### 用 AltServer（推荐）

1. Windows 下载 AltServer：https://altstore.io/
2. 安装并打开 AltServer
3. iPhone 连电脑，信任此电脑
4. AltServer 点 **Install AltStore** → 选你的 iPhone
5. 输入 Apple ID 和密码
6. 装完后，iPhone 上有 AltStore
7. 把 IPA 文件发到 iPhone（AirDrop / 微信 / 邮件）
8. 在 iPhone 上用 AltStore 打开 IPA 安装

### 或者用 Sideloadly

1. Windows 下载 Sideloadly：https://sideloadly.io/
2. 打开 Sideloadly
3. 拖入 IPA 文件
4. 输入 Apple ID
5. 点 Start
6. 自动装到 iPhone

---

## 重要说明

### 签名有效期
- 免费 Apple ID 签名的 App **7 天后过期**
- 7 天后要重新用 AltStore/Sideloadly 签名安装
- 永久使用需要 $99/年 Apple Developer Program

### Microphone Injection 权限
- 需要 iOS 18.2+
- 可能需要额外的 entitlement（权限配置）
- 真机测试才能确认 WhatsApp 是否支持

### 编译失败怎么办
1. 看 Actions 页面的红色错误日志
2. 把错误信息发给我，我帮你修

---

## 输出说明

编译完成后，Actions 页面会显示：
```
BUILD: PASS
SIGNING: MISSING  （需要 AltServer/Sideloadly 手动签名）
IPA PATH: build/ipa/MOQGOCallInjectionTest.ipa
```

---

## 常见问题

**Q: GitHub Actions 免费额度够吗？**
A: 个人账号每月 2000 分钟 macOS 时间，每次编译约 10 分钟，够你测试很多次。

**Q: 编译要多久？**
A: 第一次约 8-10 分钟（要下载 Xcode），后续约 5 分钟。

**Q: 编译出的 IPA 能直接装吗？**
A: 不能。是 unsigned 的，需要 AltServer/Sideloadly 重新签名。

**Q: Microphone Injection 能用吗？**
A: 必须真机测试才知道。编译成功不代表 API 可用。
