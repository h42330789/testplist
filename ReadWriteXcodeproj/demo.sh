#!/bin/sh
export LC_ALL=en_US.UTF-8

#### 使用PlistBuddy从Info.plist里读取
infoPlistPath="/Users/macbookpro/Documents/study/HelloPod/HelloPod/Info.plist"
bundleDisplayName=`/usr/libexec/PlistBuddy -c "Print CFBundleDisplayName" $infoPlistPath`
# APP版本号，如1.0.1, 在新版xcode生成的项目里可能是MARKETING_VERSION，或者根本不存在，则需要去project.pbxproj里去读取
bundleVersion=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $infoPlistPath`
# APP的build版本，一般使用数字，如1，在新版xcode生成的项目里可能是CURRENT_PROJECT_VERSION，或者不存在，则需要去project.pbxproj里去读取
bundleBuildVersion=`/usr/libexec/PlistBuddy -c "Print CFBundleVersion" $infoPlistPath`
# APP的bundleId，如com.ab.xyz 在新版xcode生成的项目里可能是PRODUCT_BUNDLE_IDENTIFIER，或者不存在，则需要去project.pbxproj里去读取
bundleId=`/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" $infoPlistPath`
echo "bundleDisplayName: $bundleDisplayName"
echo "bundleVersion: $bundleVersion"
echo "bundleBuildVersion: $bundleBuildVersion"
echo "bundleId: $bundleId"



#### 使用xcodeProj从project.pbxproj里读取
rubyPath=`which ruby`
rubyScriptPath="/Users/macbookpro/Desktop/test/xcodeprojTool.rb"
xcodeprojPath="/Users/macbookpro/Documents/study/HelloPod/HelloPod.xcodeproj"
infoPlistPath="/Users/macbookpro/Documents/study/HelloPod/HelloPod/Info.plist"
paramPlistPath="./param.plist"
findTargetName="HelloPod"
readConfig="Release" # Release Debug All
writeConfig="All"
# 读取版本号
$rubyPath $rubyScriptPath "read" $xcodeprojPath $findTargetName $readConfig "MARKETING_VERSION" $paramPlistPath
# 读取编译版本号
$rubyPath $rubyScriptPath "read" $xcodeprojPath $findTargetName $readConfig "CURRENT_PROJECT_VERSION" $paramPlistPath
# 读取bundleId
$rubyPath $rubyScriptPath "read" $xcodeprojPath $findTargetName $readConfig "PRODUCT_BUNDLE_IDENTIFIER" $paramPlistPath
# 读取App名称
$rubyPath $rubyScriptPath "read" $xcodeprojPath $findTargetName $readConfig "INFOPLIST_KEY_CFBundleDisplayName" $paramPlistPath
# 修改内容

# 修改版本号
$rubyPath $rubyScriptPath "write" $xcodeprojPath $findTargetName $writeConfig "MARKETING_VERSION" "1.12.002"
# 修改编译版本号
$rubyPath $rubyScriptPath "write" $xcodeprojPath $findTargetName $writeConfig "CURRENT_PROJECT_VERSION" "88"
# 修改bundleId
$rubyPath $rubyScriptPath "write" $xcodeprojPath $findTargetName $writeConfig "PRODUCT_BUNDLE_IDENTIFIER" "www.ab.com"
# 修改App名称
$rubyPath $rubyScriptPath "write" $xcodeprojPath $findTargetName $writeConfig "INFOPLIST_KEY_CFBundleDisplayName" "bestAp"