# 可选的 Mac 验证

本项目不要求购买 Mac。Windows 用户请用 README_GITHUB_BUILD.md 的 GitHub Actions 和免费签名方案。

如果已经有 Mac，可用支持 iOS 18.2 SDK 或更新版本的 Xcode 打开原 MOQGOCallInjectionTest.xcodeproj，选个人 Team、连接 iPhone、按系统提示完成开发者信任和开发者模式，再编译运行。

权限申请、系统通知以及测试操作以 README.md 为准。没有收到注入通知时应显示 UNKNOWN；不能把 NO 直接解释为永久不支持 WhatsApp。先检查系统开关、App 权限、通话状态和音频路线，再用普通电话/FaceTime 对照。

只有真机通话中另一端实际听到测试语音、且排除了扬声器到麦克风的声学串音，才能记录注入通过。Xcode 编译成功不是功能通过。
