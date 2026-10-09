# MOQGOCallInjectionTest

在原项目内验证 iOS 18.2+ 的语音注入。编译、安装、系统可用性和对端听到语音是四个不同结果。

## 本次修复

- 使用 AVAudioApplication 的真实注入权限查询和申请。
- 使用 AVAudioSession.setPreferredMicrophoneInjectionMode(.spokenAudio / .none)。
- 监听 microphoneInjectionCapabilitiesChangeNotification 的 Boolean 值；未收到通知显示 UNKNOWN，不捏造 YES 或 NO。
- 持续保留语音合成器和文件播放器；记录错误、音频中断和媒体服务重置。
- 支持导入 Windows 生成的 WAV / MP3 / M4A 外语语音进行单文件测试，尚未连接实时 WebSocket。
- 提供诊断报告；播放被请求、播放器启动和系统模式设置成功都不会自动标记通话 PASS。
- 构建检查 SDK >= 18.2、iPhone ARM64 二进制、权限说明、注入接口引用和源提交 SHA。

## 首次真机测试

1. 用 README_GITHUB_BUILD.md 的免费 Windows 方案安装新构建，旧第 16 次构建不能验证注入。
2. 在设置 > 辅助功能 > 音频与视觉 > 在通话中添加音频打开总开关。
3. **先打开本 App**，申请并允许权限，启用注入。此时没有通话，可用性可能为 NO 或 UNKNOWN。
4. 戴耳机；用 WhatsApp 发起通话，并让另一台设备接听。保持 WhatsApp 麦克风未静音。
5. 回到本 App，查看权限、模式以及可用性通知日志。若未知，保持本 App 已启动，重新建立一次通话。
6. 点 Play Test Speech，问对端是否听见完整英文测试句。
7. 点 Disable Injection，再测试；此时播放按钮禁用。需要进一步排除声学串音时，在同一设备的其它普通播放器播放测试句作为对照，并保持耳机音量低、麦克风远离耳机。
8. 若 WhatsApp 未成功，以普通电话或 FaceTime 通话做相同测试，区分接口/权限问题与 WhatsApp 支持问题。
9. 用 Share Diagnostic Report 保存结果，填写设备型号、WhatsApp 版本及实际对端听觉结果。

**不要用 WhatsApp 静音做“只传译声”的测试。苹果说明：输入静音时注入也会静音。**

## Windows 语音文件测试

Windows 的 TTS 先输出一段短外语 PCM WAV、MP3 或 M4A。通过 iCloud Drive 或已有文件传输方式送入 iPhone“文件”；也可使用 Apple 文件共享复制到本 App 的 Documents。点击 Import Windows TTS Audio 选择文件，再点击 Play Imported Speech into Call。

这一步验证外部语音文件的播放/注入链路。它不是实时翻译，也未验证 App 在后台或锁屏后持续工作。单文件上限 20 MB。

## 验收边界

| 层次 | 成功证据 |
| --- | --- |
| COMPILE | 新提交的 Actions 实际 xcodebuild 成功 |
| IPA_STRUCTURE | package-report.json 通过，SHA256SUMS 校验一致 |
| INSTALL | 免费重签后 App 在真机启动，权限请求正常 |
| INJECTION | 真实通话中对端听到语音，耳机测试排除扬声器串音 |
| WINDOWS_AUDIO | Windows TTS 文件导入后对端实际听到 |
| REALTIME_TRANSLATION | 实时传输、延迟、断线恢复、后台运行分别验证 |
| RECEIVE_TRANSLATION | 独立的对端音频采集输入送入 Windows STT/翻译，并验证中文结果 |

## 接收对方声音：尚未实现

Microphone Injection 是发送方向的接口，不是 WhatsApp 音频读取接口。本项目没有对端语音采集、麦克风音频上传、WebSocket、Whisper、Qwen 或 Spark 集成代码。NSMicrophoneUsageDescription 只是用途声明，不等于已经实现录音。

不能把 WhatsApp 麦克风当成可以由本 App 同时随意读取的输入，也不能假设 AVAudioEngine 的输入就是对方通话音轨。可评估的后续采集路线：

- 保持 iPhone 通话：单独验证外部 USB 音频接口/硬件线路能否把接收音频送入 Windows；这需要硬件和真机测试。
- 使用手机扬声器和 Windows 麦克风作临时概念验证，会有回声、噪声及译声被重复识别的问题。
- 若可以改用 Windows WhatsApp 通话，可独立评估 Windows 的系统音频采集和虚拟麦克风方案；那是另一个部署路径，不是本 iPhone 注入 PoC 已经完成的功能。

先验证发送注入，再根据可用的接收音频来源接上已有 AI 服务。无需购买 Mac。

## 官方依据

- 苹果注入示例：https://developer.apple.com/documentation/avfaudio/adding-synthesized-speech-to-calls
- 苹果静音限制：https://developer.apple.com/documentation/avfaudio/avaudiosession/microphoneinjectionmode
- Windows 免费签名：https://sideloadly.io/
- AltStore Classic Windows：https://faq.altstore.io/altstore-classic/how-to-install-altstore-windows
