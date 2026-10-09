# 原仓库云编译和免费安装

继续使用 https://github.com/moqgo/MOQGOCallInjectionTest ，不要创建新仓库。

## 更新原仓库

替换修复包中的文件，并新增 scripts/verify_ipa.py。真正生效的工作流是根目录的 .github/workflows/ios-build.yml；原先位于多重嵌套目录的同名 yml 不会被 GitHub 执行，可按补丁删除。

网页操作：逐个打开已有文件 > 编辑 > 替换内容 > Commit changes。新文件用 Add file > Create new file，输入 scripts/verify_ipa.py。不要把替换文件包中的文件夹当作新的顶层项目上传，也不要把补丁压缩包直接上传当源码。

使用 Git 时，在原项目工作目录执行：

```powershell
git fetch origin
git switch -c fix/ios-microphone-injection origin/main
git apply --check .\MOQGOCallInjectionTest-fix.patch
git apply .\MOQGOCallInjectionTest-fix.patch
git diff --check
git add .gitignore MOQGOCallInjectionTest/ContentView.swift MOQGOCallInjectionTest/Info.plist .github/workflows README.md README_GITHUB_BUILD.md README_MAC_BUILD.md scripts/verify_ipa.py
git commit -m "Implement microphone injection and verify unsigned IPA packaging"
git push -u origin fix/ios-microphone-injection
```

补丁基于 02285d089628cec235dfb2a00f8c5a1a6844a936 的源码状态。若远端已变更，先检查差异，勿强制覆盖。

## 编译和下载

在 fix/ios-microphone-injection 分支提交，不改 main。Actions > iOS Build > 选择新提交的运行，确认分支名和提交 SHA。也可 Run workflow 选择该分支手动触发。新工作流使用 macOS 15 的 Xcode 16.4（iOS 18.5 SDK），并实际检查 SDK >= 18.2。

下载 MOQGOCallInjectionTest-build-运行编号 并解压，包含：

- MOQGOCallInjectionTest-unsigned.ipa
- SHA256SUMS.txt
- package-report.json（结构与二进制接口引用检查）
- toolchain.txt（Xcode、SDK、提交 SHA）
- build.log

上传日志的步骤在失败时也会运行。因此有 Artifact 不等于编译成功，务必看整个运行的结论和 package-report.json。不要用第 16 次的旧 app.ipa 验证新功能。

## 免费 Windows 安装：Sideloadly

1. 从 https://sideloadly.io/ 下载官方 Windows 版本，按网站说明准备 Apple iTunes/iCloud 组件。不要为了本任务购买 Mac 或开发者账号。
2. iPhone 用 USB 连接 Windows，解锁，在手机选择信任电脑；先确认 Apple 设备工具能识别手机。
3. Sideloadly 选择 iPhone，把解压得到的 unsigned.ipa 拖进去，用免费 Apple ID 签名并安装。密码与验证码只在本机官方登录流程输入。
4. 根据系统提示完成“设置 > 通用 > VPN与设备管理”中的开发者信任；开发安装需开启“设置 > 隐私与安全性 > 开发者模式”，按手机提示重启和确认。
5. 打开 MOQGO Injection Test，确认新界面有 Import Windows TTS Audio 和 Share Diagnostic Report。
6. 免费签名通常 7 天有效，按工具提示刷新/重签。iOS 权限与 WhatsApp 支持仍须真机验证。

AltStore Classic + AltServer 也是免费替代，按官方 Windows 指南：https://faq.altstore.io/altstore-classic/how-to-install-altstore-windows 。AltStore PAL 不是这里的任意 IPA 安装路线。

安装失败时保留完整安装日志，记录错误码、工具版本、实际 iOS 版本和驱动能否识别设备；不要仅反复重试。分享前隐藏 Apple ID、UDID、验证码等私人信息。

## 重要限制

无签名 IPA 不能直接点开安装。此代码没有新增需付费账号的自定义 entitlement，按苹果示例使用系统服务开关和注入用途说明；免费签名后能否运行仍是安装测试，不能靠源码保证。

本修复在 Windows 上完成静态检查，尚未重新通过 Xcode 编译。新 Actions 编译成功后也仅证明编译和打包，最终通话结果仍为 NOT_TESTED。
