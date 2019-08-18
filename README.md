# IpaBuildScript
## 配置
1、将 ``ipa_build.sh`` 以及 ``Export.plist`` 两个文件放到 iOS 项目的根目录中，打开 ``ipa_build.sh``，更改配置相关常量
```shell
# 常量配置
APP_NAME="{目标名称}"  #e.g."DemoApp"
EXPORT_PLIST="Export.plist"
PACKAGE_NAME="autoPackage"

CONFIGURATION="Debug"
METHOD="development"

WORK_SPACE="{workspace工程文件}" #e.g."DemoApp.xcworkspace"
PROJECT="{项目工程文件}" #e.g."DemoApp.xcodeproj"
```

2、打开 ``Export.plist``，更改其 {teamId} 自己账号的 id

## 使用
```shell
${your-project-root}> ./ipa_build
```

## 补充
为了拓展脚本的易用性，完整脚本内容会有以下几点补充： 
>- 增加 configuration、method 两个参数的传入
>- 从项目的 info.plist 文件中截取应用的版本名、版本号来重命名文件以作版本区分
>- 复制生成的 ipa 文件路径到粘贴板，以便后续上传等操作
>- 统计打包脚本运行时长
