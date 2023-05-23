#!/usr/bin/ruby
# https://github.com/CocoaPods/Xcodeproj
require 'xcodeproj'

# 读取里buildSetting里的数据
def readBuildSetting(xcodeprojPath, findTargetName, findConfigName, findKey)
    # 读取xcode的配置信息, xxx/xxx/xx.xcodeproj
     project = Xcodeproj::Project.open(xcodeprojPath)
    # 遍历target、config是否一直
     project.targets.each do |target|
         targetName = target.name
         target.build_configurations.each do |config|
             configName = config.name
             build_settings = config.build_settings
             if (targetName == findTargetName) && (configName == findConfigName)
                 # 查找到对应的build_settings后，读取对应的key
                 findValue = config.build_settings[findKey]
                 # 将查找的内容，存放到plist里
                 puts "#{findKey}: #{findValue}"
                 return
             end
         end
     end
 end

 # 修改里buildSetting里的数据
def updateBuildSetting(xcodeprojPath, findTargetName, findConfigName, updateKey, updateValue)
    # 读取xcode的配置信息, xxx/xxx/xx.xcodeproj
    project = Xcodeproj::Project.open(xcodeprojPath)
    # 遍历target、config是否一直
    project.targets.each do |target|
        targetName = target.name
        target.build_configurations.each do |config|
            configName = config.name
            build_settings = config.build_settings
            if (targetName == findTargetName) && (configName == findConfigName)
                # 修改内容
                config.build_settings[updateKey] = updateValue
            end
        end
    end
   # 保存修改
    project.save()
end