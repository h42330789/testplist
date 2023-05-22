# 保证utf8编码，不乱码
export LC_ALL=en_US.UTF-8
echo "====github mainfest.plist start======"
DATE="$(date +%Y%m%d_%H%M%S)"
# 当前shell所在的路径
fromShellPath=`pwd`
# plist仓库地址
toGitPath="/Users/macbookpro/Documents/study/TestPlist"
# plist模板地址
demoPlistPath="/Users/macbookpro/Documents/study/TestPlist/demo.plist"
# 创建新的
# 这里让plist的名称跟ipa的名称一致，方便后续的处理
addPlistPath="$toGitPath/$DATE.plist"
cp $demoPlistPath $addPlistPath
# 修改plist
/usr/libexec/PlistBuddy -c "Set :items:0:metadata:bundle-identifier com.abc.test" $addPlistPath
/usr/libexec/PlistBuddy -c "Set :items:0:metadata:bundle-version 1.0.1" $addPlistPath
/usr/libexec/PlistBuddy -c "Set :items:0:metadata:bundle-version 99" $addPlistPath
/usr/libexec/PlistBuddy -c "Set :items:0:metadata:title test" $addPlistPath
/usr/libexec/PlistBuddy -c "Set :items:0:assets:0:url http://127.0.0.1:8090/test/$DATE.ipa" $addPlistPath
# 进入plist的github的本地仓库
cd $toGitPath
# 将新增的plist添加到仓库里并提交
git add $addPlistPath
git commit -m "add new"
git push --force
# 返回shell原本的执行路径
cd $fromShellPath

# 现在就能通过访问github上的plist了
# https://raw.githubusercontent.com/用户名/仓库名/main/xxx.plist
echo "====github mainfest.plist start======"