#!/bin/sh
#源ipa名
SOURCE_IPA="JXY_appstore_test_V1.0.9_V1_20151005.ipa" 

CURRENT_DIR=`pwd`
#工作目录     
WORK_DIR="${CURRENT_DIR}/SubChannelPack"
#母包名
TEMP_NAME="${SOURCE_IPA%%.ipa}"
#app程序名
APP_NAME="jxy.app"


echo "==========================当前脚本运行目录:${CURRENT_DIR}" 
#删除，重新建立工作目录
echo "==========================删除并创建干净的工作目录:${WORK_DIR}"
rm -rdf ${WORK_DIR}  
mkdir ${WORK_DIR} 

#解压母包文件
if [ ! -e "${CURRENT_DIR}/${SOURCE_IPA}" ]; then
	echo "==========================源ipa不存在:${CURRENT_DIR}/${SOURCE_IPA}"
	exit -1	
fi
echo "==========================解压源ipa到目录:${WORK_DIR}"
unzip -q ${CURRENT_DIR}/${SOURCE_IPA} -d ${WORK_DIR}    

echo "==========================替换新证书"
cp GuangyvDev20151006.mobileprovision ${WORK_DIR}/Payload/jxy.app/embedded.mobileprovision

echo "==========================进入工作目录:${WORK_DIR}"
cd ${WORK_DIR}

echo "==========================根据mobileprovision生成entitlements.plist"
/usr/libexec/PlistBuddy -x -c "print :Entitlements " /dev/stdin <<< $(security cms -D -i Payload/jxy.app/embedded.mobileprovision) > entitlements.plist
# /usr/libexec/PlistBuddy -c 'Set :get-task-allow true' entitlements.plist

echo "==========================删除旧签名"
rm -rf Payload/${APP_NAME}/_CodeSignature

echo "==========================重新生成签名"
/usr/bin/codesign -f -s "iPhone Developer: Hu Peng" --resource-rules Payload/${APP_NAME}/ResourceRules.plist --entitlements entitlements.plist Payload/${APP_NAME}


TARGET_IPA="${TEMP_NAME}_recodesign.ipa"

echo "==========================重新生成ipa包:${TARGET_IPA}"
zip -qr ${TARGET_IPA} Payload