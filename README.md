# MOQGOCallInjectionTest - iPhone Microphone Injection PoC

## 目标
验证 iOS 18.2+ 的 Microphone Injection API 能否把测试语音注入 WhatsApp Voice Call。

## 系统要求
- iPhone 真机（模拟器不支持）
- iOS 18.2 或更高版本
- WhatsApp 最新版

## 编译步骤

### 方法 1：用 Mac + Xcode（推荐）
1. 把整个 `MOQGOCallInjectionTest` 文件夹复制到 Mac
2. 用 Xcode 打开 `MOQGOCallInjectionTest.xcodeproj`
3. 选择你的 iPhone 作为目标设备
4. 点 Run（▶️）编译安装

### 方法 2：用云编译服务
如果没有 Mac，可以用：
- GitHub Actions + Xcode Cloud
- 或者在线 iOS 编译服务

## 测试步骤

### 准备
1. **设备 A**：安装 MOQGOCallInjectionTest，登录 WhatsApp
2. **设备 B**：另一个 WhatsApp 账号（可以是朋友的手机）

### 测试流程
1. 设备 A → 设备 B 发起 WhatsApp Voice Call
2. 设备 B 接听
3. 设备 A 保持通话，打开 MOQGOCallInjectionTest
4. 检查 `Injection Available` 是否显示 `YES`
5. 点击 `Enable Injection`
6. 点击 `Play Test Speech`
7. **关键**：设备 B 必须实际听到 "Hello, this is a MOQGO translation test."

### 系统设置（必须开启）
在设备 A 上：
```
Settings → Accessibility → Audio & Visual → Add Audio in Calls → 开启
```

## 验收标准

只有设备 B 实际听到测试语音，才算 PASS。

### 输出模板
```
IOS_VERSION: [你的 iOS 版本]
DEVICE_MODEL: [你的 iPhone 型号]
WHATSAPP_VERSION: [WhatsApp 版本]
MICROPHONE_INJECTION_PERMISSION: GRANTED / DENIED / SERVICE_DISABLED
INJECTION_AVAILABLE_DURING_WHATSAPP_CALL: YES / NO
REMOTE_SIDE_HEARD_TEST_AUDIO: YES / NO
WHATSAPP_CALL_INJECTION: PASS / UNAVAILABLE / FAIL
```

## 注意事项
- 不要因为代码编译成功就标 PASS
- 必须真机 WhatsApp Call 验收
- 模拟器不支持 Microphone Injection
- 需要 iOS 18.2+

## 如果 PASS
立即进入第二阶段：
- iPhone 实时麦克风 → WebSocket → whisper → qwen3 → Spark TTS → Microphone Injection → WhatsApp Call
