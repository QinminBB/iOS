#!/bin/bash
#--------------------------------------------
# 功能：FanRen工程Pulish脚本文件，实现item-service协议，创建网页链接。
# 注意：本脚本，在打包脚本ipa_pack_debug.sh 使用之后使用。
# 使用：
#		./ipa_publish_debug.sh <pakageName> <plistName> <中文名>
#
# 作者：Diro.K
# 创建日期：2013/09/11
#--------------------------------------------

if [[ $# -ne 3 ]]; then
	echo "脚本请在打包完成之后使用"
	echo "请输入包名、对应的plist名称和中文渠道名简写, 如swkn 91 上网快鸟"
	exit -1
fi

package_name=$1
plist_name=$2
qudao_name=$3

# 脚本路径
shell=`pwd`
# 工程路径
cd ./../../fanren/proj.ios
project_path=`pwd`

# jenkins空间地址 
publish_url="http://192.168.12.44:8080/job/ipa_2.1/ws"
# ipa发布地址 自己配地址吧。。。。
production_path=${JENKINS_HOME}/jobs/ipa_2.1/workspace


# Production路径
page_path="./../../../../../../../../Production/fanren2iOS/"
# page_path="./../../../../../../192.168.1.197/Production/fanren2iOS/"
if [[ ! -d  ${page_path} ]]; then
	echo "error! ${page_path}"
	echo "指定的生成包的目录不存在，请到ipa_pack_debug.sh 524行修改，感谢您的支持，请挂机"
	exit -1
fi

#ipa生成路径
cd ${page_path}

ipaFile="1.0.2.1"
echo $ipaFile

if [[ ! -d "${ipaFile}" ]]; then
	mkdir "${ipaFile}"
fi

cd "${ipaFile}"
ipaPath=`pwd`


# 创建发布产物目录
cd $production_path

rm -rf ${package_name}

# 创建对应的包文件目录
if [[ ! -d $package_name ]]; then
	mkdir $package_name
fi

# 将产物相关文件放到package_name对应目录下

# ipa包
cd $ipaPath
ipa_name=`ls -r | grep $qudao_name | awk 'NR==1{print}'`
cp -f $ipa_name ${production_path}/$package_name/fanren.ipa

cd ${production_path}/$package_name
cp fanren.ipa ./tmp.zip
unzip tmp.zip
plistName=$(pwd)/Payload/*.app/Info.plist
echo $plistName

cd $project_path/agent

# avatar图片
if [[ ! -d $plist_name ]]; then
	echo "进入图片文件夹错误，退出"
	exit -1
fi
cd $plist_name
cp -f Icon.png $production_path/$package_name/
cp -f iTunesArtwork $production_path/$package_name/iTunesArtwork.png


cd $production_path/$package_name

#取buildversion值
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" ${plistName})
#取bundleIdentifier
bundleIdentifier=$(/usr/libexec/PlistBuddy -c "print CFBundleIdentifier" ${plistName})

titleName="凡人修真"

echo "$bundleVersion"
echo "$bundleIdentifier"


# publish_url="http://192.168.12.44"
# publish_url="http://127.0.0.1"
ipa_download_url="${publish_url}/${package_name}/fanren.ipa"
displayImage_path="${publish_url}/${package_name}/Icon.png"
fullsizeImage_path="${publish_url}/${package_name}/iTunesArtwork.png"

ios_install_url="itms-services://?action=download-manifest&url=${publish_url}/${package_name}/manifest.plist"

echo $bundleVersion  $bundleIdentifier
echo $ipa_download_url   $displayImage_path  $fullsizeImage_path

rm $production_path/$package_name/tmp.zip
rm -rf $production_path/$package_name/Payload/


#生成install的html文件
cat << EOF >index.html
<!DOCTYPE HTML>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>安装_${titleName}</title>
	</head>

	<body>
	<br>
	<br>
	<br>
	<p align=center>
		<font size="8">
		<a href="${ios_install_url}">Install ${titleName}_${package_name}</a>
		</font>
	</p>
	</body>
</html>
EOF

#生成plist文件
cat << EOF > manifest.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>items</key>
	<array>
		<dict>
			<key>assets</key>
			<array>
				<dict>
					<key>kind</key>
					<string>software-package</string>
					<key>url</key>
					<string>${ipa_download_url}</string>
				</dict>

				<dict>
					<key>kind</key>
					<string>display-image</string>
					<key>needs-shine</key>
					<true/>
					<key>url</key>
					<string>${displayImage_path}</string>
				</dict>

				<dict>
					<key>kind</key>
					<string>full-size-image</string>
					<key>needs-shine</key>
					<true/>
					<key>url</key>
					<string>${fullsizeImage_path}</string>
				</dict>
			</array><key>metadata</key>
	           	<dict>
					<key>bundle-identifier</key>
					<string>${bundleIdentifier}</string>
					<key>bundle-version</key>
					<string>${bundleVersion}</string>
					<key>kind</key>
					<string>software</string>
					<key>subtitle</key>
					<string>fanren</string>
					<key>title</key>
					<string>${titleName}</string>
	           	</dict>
		</dict>
	</array>
</dict>
</plist>

EOF

#上传到svn
# svn cleanup $production_path/Publish
# svn up $production_path/Publish/$package_name
# svn add --force $production_path/Publish/$package_name
# svn commit -m "更新$package_name itms-services 资源"  $production_path/Publish/$package_name
echo "================= END ===================="
