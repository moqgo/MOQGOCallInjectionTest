# MOQGOCallInjectionTest - Mac 编译傻瓜教程

拿到 Mac 后，按这个步骤一步步来，不用懂 iOS 开发也能搞定。

---

## 第 0 步：你需要准备什么

- 一台 Mac（任何型号都行，M1/M2/M3/Intel 都可以）
- iPhone 数据线（USB-C 或 Lightning，看你的 iPhone）
- Apple ID（免费的就行，不需要付费开发者账号）

---

## 第 1 步：安装 Xcode

1. 打开 Mac 上的 **App Store**
2. 搜索 **Xcode**
3. 点 **获取/安装**（大概 10GB，等它下完）
4. 安装完后打开 Xcode，同意协议，等它装完额外组件

---

## 第 2 步：打开项目

1. 把整个 `MOQGOCallInjectionTest` 文件夹复制到 Mac 桌面
2. 双击打开 `MOQGOCallInjectionTest.xcodeproj`
3. Xcode 会自动打开项目

---

## 第 3 步：登录 Apple ID

1. Xcode 顶部菜单 → **Xcode** → **Settings**（或 Preferences）
2. 点 **Accounts** 标签
3. 点左下角 **+** 号
4. 选 **Apple ID**
5. 输入你的 Apple ID 和密码登录

---

## 第 4 步：连接 iPhone

1. 用数据线把 iPhone 连到 Mac
2. iPhone 上会弹窗 **"是否信任此电脑？"** → 点 **信任**
3. 输入 iPhone 锁屏密码
4. 等 Xcode 识别到你的 iPhone（顶部工具栏会出现你的手机型号）

---

## 第 5 步：配置签名（Signing & Capabilities）

1. 在 Xcode 左侧导航器，点最上面的 **MOQGOCallInjectionTest** 项目图标
2. 中间会出现项目设置
3. 点 **TARGETS** 下面的 **MOQGOCallInjectionTest**
4. 点 **Signing & Capabilities** 标签
5. 勾选 **Automatically manage signing**
6. **Team** 下拉框 → 选你的 Apple ID（如果没有，点 Add Account，登录一下）
7. 如果 Bundle ID 冲突（报错说已存在）：
   - 把 `com.moqgo.callinjectiontest` 改成 `com.moqgo.callinjectiontest123`（随便加几个数字）
   - 或者改成你自己的：`com.你的名字.callinjectiontest`

---

## 第 6 步：编译安装

1. Xcode 顶部工具栏，中间的设备选择器 → 选你的 iPhone
2. 点左上角 **运行按钮**（▶️），或者按 `Cmd + R`
3. 第一次编译要等 2-5 分钟
4. 编译成功后，App 会自动装到你的 iPhone 上

---

## 第 7 步：iPhone 上信任开发者

第一次装完，iPhone 打开 App 会提示 **"开发者未受信任"**。解决：

1. iPhone 打开 **设置**
2. **通用** → **VPN与设备管理**
3. 找到你的 Apple ID 对应的开发者证书
4. 点进去 → 点 **信任**
5. 确认信任
6. 现在可以打开 App 了

---

## 第 8 步：开启系统级 Microphone Injection

这一步必须做，否则 Injection 用不了：

1. iPhone 打开 **设置**
2. **辅助功能**（Accessibility）
3. **音频/视觉**（Audio & Visual）
4. 找到 **通话中的音频注入**（Add Audio in Calls）
5. 打开开关

---

## 第 9 步：WhatsApp Call 实测

### 准备
- **手机 A**：你的 iPhone（装了 MOQGOCallInjectionTest），登录 WhatsApp
- **手机 B**：另一个 WhatsApp 账号（朋友的手机、或者你的小号）

### 测试流程
1. 手机 A 用 WhatsApp 打给手机 B
2. 手机 B 接听
3. 手机 A 保持通话，**切到 MOQGOCallInjectionTest App**
4. 看 App 上的状态：
   - `Microphone Injection Permission` 应该是 `GRANTED`
   - `Injection Available` 应该是 `YES`
5. 点 **Request Permission**（如果还是 UNDETERMINED）
6. 点 **Enable Injection**
7. 点 **Play Test Speech**
8. **关键：听手机 B 有没有听到 "Hello, this is a MOQGO translation test."**

---

## 第 10 步：记录结果

把以下信息填好发给我：

```
IOS_VERSION: （你的 iOS 版本，设置→通用→关于本机）
DEVICE_MODEL: （你的 iPhone 型号）
WHATSAPP_VERSION: （WhatsApp 设置里看版本号）
MICROPHONE_INJECTION_PERMISSION: GRANTED / DENIED / SERVICE_DISABLED
INJECTION_AVAILABLE_DURING_WHATSAPP_CALL: YES / NO
REMOTE_SIDE_HEARD_TEST_AUDIO: YES / NO
WHATSAPP_CALL_INJECTION: PASS / UNAVAILABLE / FAIL
```

**注意：只有手机 B 实际听到测试语音，才能写 PASS。**

---

## 常见问题

### Q: Xcode 编译报错 "No profile for com.moqgo.callinjectiontest found"
A: 去 Signing & Capabilities，把 Bundle Identifier 改成别的，比如 `com.moqgo.test123`

### Q: iPhone 上 App 闪退
A: 检查第 7 步，有没有信任开发者证书

### Q: Injection Available 显示 NO
A: 检查第 8 步，系统设置里的 Add Audio in Calls 有没有开

### Q: 编译成功但 iPhone 上没出现 App
A: 检查数据线有没有插好，iPhone 有没有解锁

### Q: WhatsApp Call 时 Injection Available 变成 NO
A: 说明 WhatsApp 不支持 Injection，标记为 UNAVAILABLE
