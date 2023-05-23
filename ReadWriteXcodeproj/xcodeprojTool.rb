#!/usr/bin/ruby
# https://github.com/CocoaPods/Xcodeproj
require 'xcodeproj'

# ruby 非空判断 https://blog.csdn.net/leinminna/article/details/110422744
# 在 Ruby 中执行 Shell 命令的 6 种方法 https://segmentfault.com/a/1190000000368191

# 增加或修改key对应的value，如果不存在就增加，如果存在不一致就修改
def changeDict(dict, key, value)
    if (dict.has_key?(key))
        oldValue = dict[key]
        if (oldValue != value)
            dict[key] = value
            return true
        end
    else
        dict[key] = value
        return true
    end
    return false
end

# 删除key，如果存在才删除
def deleteDict(dict, key)
    if (dict.has_key?(key))
        dict.delete(key)
        return true
    end
    return false
end

# bool值取或运输
def boolOr(a, b)
    if (a == false and b == false)
        return false
    end
    return true
end

# bool值取与运输
def boolAnd(a, b)
    if (a == true and b == true)
        return true
    end
    return false
end

def updateParamPlist(paramPlistPath, key, value)
    oldVale = `/usr/libexec/PlistBuddy -c "Print #{key}" #{paramPlistPath}`
    if oldVale.nil? || oldVale.empty?
        # 之前不存在，则添加
        `/usr/libexec/PlistBuddy -c 'Add :#{key} string #{value}' #{paramPlistPath}`
    else
        # 之前存在，则修改
        `/usr/libexec/PlistBuddy -c 'Set :#{key} #{value}' #{paramPlistPath}`
    end
    puts "read key: #{key} oldVale: #{oldVale} newValue: #{value}"
end

# 读取xcoceproj里buildSetting里的数据
def readBuildSetting(xcodeprojPath, findTargetName, findConfigName, findKey, paramPlistPath)

    # puts "xcodeprojPath: #{xcodeprojPath}"
    # puts "findTargetName: #{findTargetName}"
    # puts "findConfigName: #{findConfigName}"
    
    project = Xcodeproj::Project.open(xcodeprojPath)

    project.targets.each do |target|
        targetName = target.name
        target.build_configurations.each do |config|
            configName = config.name
            build_settings = config.build_settings
            if (targetName == findTargetName) && ((findConfigName == "All") || (configName == findConfigName))
                findValue = config.build_settings[findKey]
                # 将查找的内容，存放到plist里
                updateParamPlist(paramPlistPath, findKey, findValue)
                puts "----------readBuildSetting---success--end---------------"
                return
            end
        end
    end
    puts "----------readBuildSetting--error--end-------------"
end

# 读取xcoceproj里buildSetting里的数据
def updateBuildSetting(xcodeprojPath, findTargetName, findConfigName, updateKey, updateValue)

    isNeedChange = false
    project = Xcodeproj::Project.open(xcodeprojPath)

    project.targets.each do |target|
        targetName = target.name
        target.build_configurations.each do |config|
            configName = config.name
            build_settings = config.build_settings
            if (targetName == findTargetName) && ((findConfigName == "All") || (configName == findConfigName))
                isNeedChange = boolOr(isNeedChange, changeDict(build_settings, updateKey, updateValue))
                # 将查找的内容，存放到plist里
                puts "----------updateBuildSetting---success--end---------------"
            end
        end
    end
   # 保存配置
   if (isNeedChange == true)
    project.save()
    end
end

# 对项目设置成自动管理
def updateAutoProfile(xcodeprojPath, findTargetName, findConfigName, newTeamId, newBundleId)

    isNeedChange = false
    project = Xcodeproj::Project.open(xcodeprojPath)

    project.targets.each do |target|
        targetName = target.name
        target.build_configurations.each do |config|
            configName = config.name
            build_settings = config.build_settings
            if (targetName == findTargetName) && ((findConfigName == "All") || (configName == findConfigName))
                # 删除手动管理相关的配置
                isNeedChange = boolOr(isNeedChange, deleteDict(build_settings, "CODE_SIGN_IDENTITY[sdk=iphoneos*]"))
                isNeedChange = boolOr(isNeedChange, deleteDict(build_settings, "CODE_SIGN_STYLE"))
                isNeedChange = boolOr(isNeedChange, deleteDict(build_settings, "DEVELOPMENT_TEAM"))
                isNeedChange = boolOr(isNeedChange, deleteDict(build_settings, "DEVELOPMENT_TEAM[sdk=iphoneos*]"))
                isNeedChange = boolOr(isNeedChange, deleteDict(build_settings, "PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]"))
                isNeedChange = boolOr(isNeedChange, deleteDict(build_settings, "PROVISIONING_PROFILE_SPECIFIER"))

                # 修改
                isNeedChange = boolOr(isNeedChange, changeDict(build_settings, "CODE_SIGN_STYLE", "Automatic"))
                isNeedChange = boolOr(isNeedChange, changeDict(build_settings, "DEVELOPMENT_TEAM", newTeamId))

                isNeedChange = boolOr(isNeedChange, changeDict(build_settings, "PRODUCT_BUNDLE_IDENTIFIER", newBundleId))
                isNeedChange = boolOr(isNeedChange, changeDict(build_settings, "CODE_SIGN_IDENTITY", "Apple Development"))
            end
        end
    end
    
    
    puts "isNeedChange #{isNeedChange}"
    # 保存配置
    if (isNeedChange == true)
        project.save()
    end
end

# 对项目设置成手动管理
def updateManualProfile(xcodeprojPath, findTargetName, findConfigName, newTeamId, newBundleId, newProfileName)

    isNeedChange = false
    project = Xcodeproj::Project.open(xcodeprojPath)

    project.targets.each do |target|
        targetName = target.name
        target.build_configurations.each do |config|
            configName = config.name
            build_settings = config.build_settings
            if (targetName == findTargetName) && ((findConfigName == "All") || (configName == findConfigName))
                 # 去掉自动管理证书，证书方
                isNeedChange = boolOr(isNeedChange, deleteDict(build_settings, "CODE_SIGN_IDENTITY"))
                isNeedChange = boolOr(isNeedChange, deleteDict(build_settings, "CODE_SIGN_STYLE"))
                # 增加手动管理证书
                isNeedChange = boolOr(isNeedChange, changeDict(build_settings, "CODE_SIGN_IDENTITY[sdk=iphoneos*]", "iPhone Distribution"))
                isNeedChange = boolOr(isNeedChange, changeDict(build_settings, "CODE_SIGN_STYLE", "Manual"))
                isNeedChange = boolOr(isNeedChange, changeDict(build_settings, "DEVELOPMENT_TEAM[sdk=iphoneos*]", newTeamId))
                isNeedChange = boolOr(isNeedChange, changeDict(build_settings, "DEVELOPMENT_TEAM", newTeamId))

                isNeedChange = boolOr(isNeedChange, changeDict(build_settings, "PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]", newProfileName))
                isNeedChange = boolOr(isNeedChange, changeDict(build_settings, "PRODUCT_BUNDLE_IDENTIFIER", newBundleId))
                isNeedChange = boolOr(isNeedChange, changeDict(build_settings, "CODE_SIGN_IDENTITY", "Apple Distribution"))
            end
        end
    end
    
    
    puts "isNeedChange #{isNeedChange}"
    # 保存配置
    if (isNeedChange == true)
        project.save()
    end
end

type=ARGV[0]
if type == "write"
    # 给buildSetting里设置信息
    xcodeprojPath = ARGV[1]
    findTargeName = ARGV[2]
    findConfigName = ARGV[3]
    updateKey = ARGV[4]
    updateValue = ARGV[5]

    updateBuildSetting(xcodeprojPath, findTargeName, findConfigName, updateKey, updateValue)
elsif type == "read"
    # 读取buildSetting里的信息
    xcodeprojPath = ARGV[1]
    findTargeName = ARGV[2]
    findConfigName = ARGV[3]
    findKey = ARGV[4]
    paramPlistPath = ARGV[5]

    readBuildSetting(xcodeprojPath, findTargeName, findConfigName, findKey, paramPlistPath)
elsif type == "autoProfile"
    # 设置自动管理证书
    xcodeprojPath = ARGV[1]
    findTargeName = ARGV[2]
    findConfigName = ARGV[3]
    newTeamId = ARGV[4]
    newBundleId = ARGV[5]

    updateAutoProfile(xcodeprojPath, findTargetName, findConfigName, newTeamId, newBundleId)
elsif type == "manualProfile"
    # 设置手动管理证书
    xcodeprojPath = ARGV[1]
    findTargeName = ARGV[2]
    findConfigName = ARGV[3]
    newTeamId = ARGV[4]
    newBundleId = ARGV[5]
    newProfileName = ARGV[6]

    updateManualProfile(xcodeprojPath, findTargetName, findConfigName, newTeamId, newBundleId, newProfileName)
end