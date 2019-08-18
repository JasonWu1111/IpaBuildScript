# IpaBuildScript
## 脚本打包步骤
首先配置一些常量
```
# 常量配置
APP_NAME="{目标名称}"  #e.g."DemoApp"
EXPORT_PLIST="Export.plist"
PACKAGE_NAME="autoPackage"

CONFIGURATION="Debug"
METHOD="development"

WORK_SPACE="{workspace工程文件}" #e.g."DemoApp.xcworkspace"
PROJECT="{项目工程文件}" #e.g."DemoApp.xcodeproj"
```
脚本打包是依靠 **xcodebuild** 命令实现的，主要的命令行有三条，实现了 Xcode 打包的各个步骤：
1、**Clean**
```shell
xcodebuild clean -workspace ${WORK_SPACE}\
                 -scheme ${APP_NAME}\
                 -configuration ${CONFIGURATION}
# 如果无workspace，可将此命令中 "-workspace ${WORK_SPACE}" 替换为 "-project ${PROJECT}"
# CONFIGURATION 参数可选择： Debug，Release
```
2、**Archive**
```shell
ARCHIVE_PATH="./${PACKAGE_NAME}/${APP_NAME}.xcarchive"
xcodebuild archive -workspace ${WORK_SPACE}\
                   -scheme ${APP_NAME}\
                   -configuration ${CONFIGURATION}\
                   -archivePath ${ARCHIVE_PATH}
# 如果无workspace，可将此命令中 "-workspace ${WORK_SPACE}" 替换为 "-project ${PROJECT}"
```
3、**Export**
```shell
# 替换Export.plist中的export方法为指定的方法，METHOD 参数可选择：development，adhoc，app-store，enterprise
sed -i '' "s/{method}/${METHOD}/g" ${EXPORT_PLIST}
EXPORT_PATH="./${PACKAGE_NAME}/${APP_NAME}"
xcodebuild -exportArchive\
           -exportOptionsPlist ${EXPORT_PLIST}\ 
           -archivePath ${ARCHIVE_PATH}\
           -exportPath ${EXPORT_PATH}\ 
           -allowProvisioningUpdates
```
其中 EXPORT_PLIST 对应的是一个必须的 plist 文件，该文件包含了分发的方式、签名、是否压缩等信息，因此需要在当前目录里新建一个 Export.plist 文件，内容如下：
```html
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<!--{}内为需要手动替换字段，{method}除外-->

	<!--是否编译二进制码-->
	<key>compileBitcode</key>
	<false/>

	<key>destination</key>
	<string>export</string>

	<!--此处{method}不需要手动替换，由脚本传入参数自动替换-->
	<key>method</key>
	<string>{method}</string>

	<!--签名方式 >> 自动-->
	<key>signingStyle</key>
	<string>automatic</string>

	<!--签名方式 >> 手动-->
	<!--<key>signingStyle</key>-->
	<!--<string>manual</string>-->
	<!--<key>provisioningProfiles</key>-->
	<!--<dict>-->
		<!--<key>{项目的bundleId}</key>-->
		<!--<string>{证书名称}</string>-->
	<!--</dict>-->

	<key>stripSwiftSymbols</key>
	<true/>

	<key>teamID</key>
	<string>{teamID}</string>

	<key>thinning</key>
	<string>&lt;none&gt;</string>
</dict>
</plist>
```
## 打包脚本补充
以上就是用 shell 脚本打包的主要命令行内容了，为了拓展脚本的易用性，完整脚本内容会有以下几点补充： 
>- 增加 configuration、method 两个参数的传入
>- 从项目的 info.plist 文件中截取应用的版本名、版本号来重命名文件以作版本区分
>- 复制生成的 ipa 文件路径到粘贴板，以便后续上传等操作
>- 统计打包脚本运行时长
