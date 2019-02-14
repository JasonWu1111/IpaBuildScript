#!/bin/bash
# 此脚本为ios ipa打包脚本，在当前项目目录下调用，请确保当前目录下包含Export.plist文件
# 脚本具体使用方式请参考 ./ipa_build_template -help
# 脚本执行的内容：clean -> archive -> export
# create by wuzhiqiang 14/2/2019

START_TIME=`date +%s`

# 常量配置
APP_NAME="{目标名称}"  # e.g."DemoApp"
INFO_PLIST="{info.plist文件路径}" #e.g."./Supporting Files/Info.plist"
EXPORT_PLIST="Export.plist"
PACKAGE_NAME="autoPackage"

CONFIGURATION="Debug"
METHOD="development"

WORK_SPACE="{workspace工程文件}" #e.g."DemoApp.xcworkspace"
#PROJECT="{项目工程文件}" #e.g."DemoApp.xcodeproj"

# 使用方式说明
if [[ -n "$1" ]] && [[ "$1" == "-help" ]] ; then
    echo "使用方式:"
    echo "$0 <configuration> <method>"
    echo
    echo "configuration 可接收参数（不传默认值为-r）："
    echo "  -d                        build configuration: Debug"
    echo "  -r                        build configuration: Release"
    echo
    echo "method 可接收参数（不传默认值为dev）："
    echo "  dev                       distribution method：development"
    echo "  adhoc                     distribution method：adhoc"
    echo "  as                        distribution method：app-store"
    echo "  ent                       distribution method：enterprise"
    exit
fi

# 处理输入参数，只识别-d, -r, dev, adhoc, as, ent 参数，打包配置和export方法均可传参或者不传参（使用默认值 CONFIGURATION="Debug", METHOD="development"）。
while [[ -n "$1" ]]
do
    case $1 in
    -d) CONFIGURATION="Debug" ;;
    -r) CONFIGURATION="Release" ;;
    dev) METHOD="development" ;;
    adhoc) METHOD="adhoc" ;;
    as) METHOD="app-store" ;;
    ent) METHOD="enterprise" ;;
    *) echo "error: Unknown args '$1'."
       exit ;;
    esac
    shift
done

if [[ ! -d ${PACKAGE_NAME} ]] ; then
    mkdir ${PACKAGE_NAME}
fi

echo "clean..."
# 如果无workspace，可将此命令中 "-workspace ${WORK_SPACE}" 替换为 "-project ${PROJECT}"
xcodebuild clean -workspace ${WORK_SPACE} -scheme ${APP_NAME} -configuration ${CONFIGURATION}

# 从info.plist文件中获取版本名、版本号用来重命名生成的ipa包
VERSION_NAME=$(awk '/CFBundleShortVersionString/{getline; print}' "${INFO_PLIST}")
VERSION_NAME=${VERSION_NAME#*"<string>"}
VERSION_NAME=${VERSION_NAME%"</string>"*}
VERSION_CODE=$(awk '/CFBundleVersion/{getline; print}' "${INFO_PLIST}")
VERSION_CODE=${VERSION_CODE#*"<string>"}
VERSION_CODE=${VERSION_CODE%"</string>"*}

DIR_NAME="v${VERSION_NAME}(${VERSION_CODE})"
FULL_NAME="${APP_NAME}-v${VERSION_NAME}(${VERSION_CODE})"

echo "archive..."
ARCHIVE_PATH="./${PACKAGE_NAME}/${FULL_NAME}.xcarchive"
# 如果无workspace，可将此命令中 "-workspace ${WORK_SPACE}" 替换为 "-project ${PROJECT}"
xcodebuild archive -workspace ${WORK_SPACE} -scheme ${APP_NAME} -configuration ${CONFIGURATION} -archivePath ${ARCHIVE_PATH}

echo "export ${METHOD}..."
EXPORT_PATH="./${PACKAGE_NAME}/${DIR_NAME}"
# 替换文件中的export方法为指定的方法
sed -i '' "s/{method}/${METHOD}/g" ${EXPORT_PLIST}
xcodebuild -exportArchive -exportOptionsPlist ${EXPORT_PLIST} -archivePath ${ARCHIVE_PATH} -exportPath ${EXPORT_PATH} -allowProvisioningUpdates

IPA_PATH="${EXPORT_PATH}/${APP_NAME}.ipa"
NEW_IPA_PATH="${EXPORT_PATH}/${FULL_NAME}.ipa"

if [[ -f ${IPA_PATH} ]] ; then
	mv ${IPA_PATH} ${NEW_IPA_PATH}
	echo "========================================================="
	echo "\"${NEW_IPA_PATH}\""
	echo "========================================================="
	# 复制ipa文件路径到粘贴板，以便后续上传等操作
	echo "\"${NEW_IPA_PATH}\"" | pbcopy
else
	echo "export failed"
fi

# 替换文件中的export方法回默认值，以便下一次使用
sed -i '' "s/${METHOD}/{method}/g" ${EXPORT_PLIST}
# 删除archive过程中生成的.xcarchive文件
rm -rf ${ARCHIVE_PATH}

# 计算此次用时时长
END_TIME=`date +%s`
echo "本次运行共计时："$((END_TIME - START_TIME))"s"