LOCAL_PATH := $(call my-dir) ===>此变量用于给出当前文件的路径,必须在Android.mk开头定义					
########Test1.apk#########
include $(CLEAR_VARS)  
LOCAL_MODULE := lantern-installer-preview  ===>apk的名字(模块名称,名字是唯一的,不能包含空格)
LOCAL_MODULE_TAGS := optional ===>当前模块所包含的标签，一个模块可包含多个标签，可以是debug、eng、tests或optional
LOCAL_SRC_FILES :=$(LOCAL_MODULE).apk   ===>当前模块包含的所有源代码文件
LOCAL_MODULE_CLASS := APPS ===>标识所编译模块最后放置的位置，ETC表示放置在/system/etc.目录下，APPS表示放置在/system/app目录下，SHARED_LIBRARIES表示放置在/system/lib目录下
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX) ===>模块前缀，在\build\core\config.mk定义
LOCAL_CERTIFICATE := platform ===>使apk获得系统权限
LOCAL_DEX_PREOPT := false
LOCAL_MULTILIB :=32  ===>指定编译目标为 32位 或 64位
LOCAL_MODULE_PATH := $(TARGET_OUT)/app    ===>安装apk的路径
include $(BUILD_PREBUILT)



