WsRootDir=`pwd`
MY_NAME=`whoami`
CONFIGPATH=$WsRootDir/device/ginreen
ARM=arm64
KERNELCONFIGPATH=$WsRootDir/kernel-3.18/arch/$ARM/configs
CUSTOMPATH=$WsRootDir/device/ginreen
RELEASEPATH=$1
BUILDINFO=$WsRootDir/build-log/buildinfo
RELEASE_PARAM=all
LOG_PATH=$WsRootDir/build-log
BASE_PRJ=gr6750_66_r_n
Mode_Path=$WsRootDir/vendor/mediatek/proprietary/modem/gr6750_66_r_n_lwctg_mp5
CPUCORE=8

PRODUCT=
VARIANT=
ACTION=
MODULE=
ORIGINAL=
COPYFILES=

clean_pl()
{
    if [ x$ORIGINAL == x"yes" ]; then
        rm $LOG_PATH/pl.log; make clean-pl
        return $?
    else
        OUT_PATH=$WsRootDir/out/target/product/$PRODUCT
        PL_OUT_PATH=$OUT_PATH/obj/PRELOADER_OBJ
        rm -f $LOG_PATH/pl.log
        rm -f $OUT_PATH/preloader_$PRODUCT.bin
        rm -rf $PL_OUT_PATH
        result=$?
        return $result
    fi
}

build_pl()
{
    if [ x$ORIGINAL == x"yes" ]; then
        make -j$CPUCORE pl 2>&1 | tee $LOG_PATH/pl.log
        return $?
    else
        OUT_PATH=$WsRootDir/out/target/product/$PRODUCT
        PL_OUT_PATH=$OUT_PATH/obj/PRELOADER_OBJ
        cd vendor/mediatek/proprietary/bootable/bootloader/preloader
        PRELOADER_OUT=$PL_OUT_PATH TARGET_PRODUCT=$PRODUCT ./build.sh 2>&1 | tee $LOG_PATH/pl.log
        result=$?
        cd -
        cp $PL_OUT_PATH/bin/preloader_$PRODUCT.bin $OUT_PATH
        return $result
    fi
}

clean_kernel()
{
    if [ x$ORIGINAL == x"yes" ]; then
        rm $LOG_PATH/k.log; make clean-kernel
        return $?
    else
        OUT_PATH=$WsRootDir/out/target/product/$PRODUCT
        KERNEL_OUT_PATH=$OUT_PATH/obj/KERNEL_OBJ
        rm -f $LOG_PATH/k.log
        rm -f $OUT_PATH/boot.img
        rm -rf $KERNEL_OUT_PATH
        result=$?
        return $result
    fi
}

build_kernel()
{
    if [ x$ORIGINAL == x"yes" ]; then
        make -j$CPUCORE kernel 2>&1 | tee $LOG_PATH/k.log
        return $?
    else
        cd kernel-3.18
        if [ x$VARIANT == x"user" ] || [ x$VARIANT == x"userroot" ];then
            defconfig_files=${PRODUCT}_defconfig
        else
            defconfig_files=${PRODUCT}_debug_defconfig
        fi
        KERNEL_OUT_PATH=../out/target/product/$PRODUCT/obj/KERNEL_OBJ
        mkdir -p $KERNEL_OUT_PATH
        while [ 1 ]; do
            make O=$KERNEL_OUT_PATH ARCH=$ARM ${defconfig_files}
            result=$?; if [ x$result != x"0" ];then break; fi
            #make -j$CPUCORE -k O=$KERNEL_OUT_PATH Image modules
            make -j$CPUCORE O=$KERNEL_OUT_PATH ARCH=$ARM CROSS_COMPILE=$WsRootDir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android- 2>&1 | tee $LOG_PATH/k.log
            result=$?; if [ x$result != x"0" ];then break; fi
            cp $KERNEL_OUT_PATH/arch/$ARM/boot/zImage-dtb ../out/target/product/$PRODUCT/kernel
            break
        done
        cd -
        return $result
    fi
}

clean_lk()
{
    if [ x$ORIGINAL == x"yes" ]; then
        rm $LOG_PATH/lk.log; make clean-lk
        return $?
    else
        OUT_PATH=$WsRootDir/out/target/product/$PRODUCT
        LK_OUT_PATH=$OUT_PATH/obj/BOOTLOADER_OBJ
        rm -f $LOG_PATH/lk.log
        rm -f $OUT_PATH/lk.bin $OUT_PATH/logo.bin
        rm -rf $LK_OUT_PATH
        result=$?
        return $result
    fi
}

build_lk()
{
    if [ x$ORIGINAL == x"yes" ]; then
        make -j$CPUCORE lk 2>&1 | tee $LOG_PATH/lk.log
        return $?
    else
        OUT_PATH=$WsRootDir/out/target/product/$PRODUCT
        LK_OUT_PATH=$OUT_PATH/obj/BOOTLOADER_OBJ
        mkdir -p $LK_OUT_PATH
        cd vendor/mediatek/proprietary/bootable/bootloader/lk
        export BOOTLOADER_OUT=$LK_OUT_PATH
        export MTK_PUMP_EXPRESS_SUPPORT=yes
        make -j$CPUCORE $PRODUCT 2>&1 | tee $LOG_PATH/lk.log
        result=$?
        cd -
        cp $LK_OUT_PATH/build-$PRODUCT/lk.bin $OUT_PATH
        cp $LK_OUT_PATH/build-$PRODUCT/logo.bin $OUT_PATH
        return $result
    fi
}

# restore code in same as before 
revert_code()
{
    echo -e "\033[33mIt's going to revert your code.\033[0m"
    read -n1 -p  "Are you sure? [Y/N]" answer
    case $answer in
        Y | y )
        echo "";;
        *)
    echo -e "\n"
        exit 0 ;;
    esac
   echo "Start revert Code...."
   echo "repo forall -c \"git clean -df\""
   repo forall -c  "git clean -df"
   echo "repo forall -c \"git co .\""
   repo forall -c "git co ."
   echo "rm -rf $LOG_PATH/*"
   rm -rf $LOG_PATH/*
   echo "rm -rf out"
   rm -rf out
   echo -e "\033[33mComplete revert code.\033[0m"
   exit 0
}

function analyze_args()
{
    ### set PRODUCT
    PRODUCT=$1

    case $PRODUCT in
        UBT|U195|X100)
        echo "PRODUCT=$PRODUCT"
        RELEASEPATH=$PRODUCT
        ORIGINAL=yes
        ;;

        *)
        echo "PRODUCT name error $PRODUCT!!!"
        exit 1
        ;;
    esac

    command_array=($2 $3 $4 $5)

    for command in ${command_array[*]}; do
        ### set VARIANT
        if [ x$command == x"user" ] ;then
            if [ x$VARIANT != x"" ];then continue; fi
            VARIANT=user
        elif [ x$command == x"debug" ] ;then
            if [ x$VARIANT != x"" ];then continue; fi
            VARIANT=userdebug
        elif [ x$command == x"eng" ] ;then
            if [ x$VARIANT != x"" ];then continue; fi
            VARIANT=eng
        elif [ x$command == x"userroot" ] ;then
            if [ x$VARIANT != x"" ];then continue; fi
            VARIANT=userroot

        ### set ACTION
        elif [ x$command == x"r" ] || [ x$command == x"remake" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=remake
        elif [ x$command == x"n" ] || [ x$command == x"new" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=new
        elif [ x$command == x"c" ] || [ x$command == x"clean" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=clean
            RELEASE_PARAM=none
        elif [ x$command == x"m" ] || [ x$command == x"make" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=m
            RELEASE_PARAM=none
        elif [ x$command == x"revert" ] ;then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=revert
            RELEASE_PARAM=none
        elif [ x$command == x"mmma" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=mmma
            RELEASE_PARAM=none
        elif [ x$command == x"mmm" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=mmm
            RELEASE_PARAM=none
        elif [ x$command == x"api" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=update-api
            RELEASE_PARAM=none
        elif [ x$command == x"boot" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=bootimage
            RELEASE_PARAM=boot
        elif [ x$command == x"system" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=systemimage
            RELEASE_PARAM=system
        elif [ x$command == x"userdata" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=userdataimage
            RELEASE_PARAM=userdata
        elif [ x$command == x"boot-nodeps" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=bootimage-nodeps
            RELEASE_PARAM=boot
        elif [ x$command == x"snod" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=snod
            RELEASE_PARAM=system
        elif [ x$command == x"userdata-nodeps" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=userdataimage-nodeps
            RELEASE_PARAM=userdata
        elif [ x$command == x"ramdisk-nodeps" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=ramdisk-nodeps
            RELEASE_PARAM=boot
        elif [ x$command == x"recovery" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=recoveryimage
            RELEASE_PARAM=recovery
        elif [ x$command == x"cache" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=cacheimage
            RELEASE_PARAM=none
        elif [ x$command == x"otapackage" ] || [ x$command == x"ota" ] ;then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=otapackage
            RELEASE_PARAM=ota
        elif [ x$command == x"otadiff" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=otadiff
            RELEASE_PARAM=none
        elif [ x$command == x"cts" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=cts
            RELEASE_PARAM=none

        ### set ORIGINAL
        #elif [ x$command == x"o" ];then
            #if [ x$ORIGINAL != x"" ];then continue; fi
            #ORIGINAL=yes

        ### set COPYFILES
        elif [ x$command == x"fc" ];then
            if [ x$COPYFILES != x"" ];then continue; fi
            COPYFILES=yes

        elif [ x$command == x"nc" ];then
            if [ x$COPYFILES != x"" ];then continue; fi
            COPYFILES=no

        ### set MODULE
        elif [ x$command == x"pl" ];then
            if [ x$MODULE != x"" ];then continue; fi
            MODULE=pl
            RELEASE_PARAM=pl
        elif [ x$command == x"k" ] || [ x$command == x"kernel" ];then
            if [ x$MODULE != x"" ];then continue; fi
            MODULE=k
            RELEASE_PARAM=boot
        elif [ x$command == x"lk" ];then
            if [ x$MODULE != x"" ];then continue; fi
            MODULE=lk
            RELEASE_PARAM=lk
        #elif [ x$command == x"dr" ];then
            #if [ x$MODULE != x"" ];then continue; fi
            #MODULE=dr
            #RELEASE_PARAM=system
        else
            if [ x$MODULE != x"" ];then continue; fi
            MODULE=$command
        fi
    done

    if [ x$VARIANT == x"" ];then VARIANT=eng; fi
    #if [ x$ORIGINAL == x"" ];then ORIGINAL=no; fi
    if [ x$ACTION == x"clean" ];then RELEASE_PARAM=none; fi
    if [ x$COPYFILES == x"" ];then
        if [ x$ACTION == x"new" ] && [ x$MODULE == x"" ];then
            COPYFILES=yes;
        else
            COPYFILES=no;
        fi
    fi
}

function main()
{
    ##################################################################
    #Check parameters
    ##################################################################
    if [ ! -d $LOG_PATH ];then
        mkdir $LOG_PATH
    fi
   
    analyze_args $1 $2 $3 $4 $5

    if [ x$ACTION == x"revert" ];then
        revert_code
    fi

    ### Check VARIANT WHEN NOT NEW
    Check_Variant

    echo "PRODUCT=$PRODUCT VARIANT=$VARIANT ACTION=$ACTION MODULE=$MODULE COPYFILES=$COPYFILES ORIGINAL=$ORIGINAL"
    echo "Log Path $LOG_PATH"

    if [ x$ACTION == x"" ];then
        echo  -e "\033[31m !!!!!!   No Such Action =$ACTION ======!!!! \033[0m"
        exit 1
    fi

    ##################################################################
    #Prepare
    ##################################################################
    Check_Space
    CUSTOM_FILES_PATH="./wind/custom_files"

    #Lancelot -s
    if [ x$COPYFILES == x"yes" ];then
        remove_mode_files    #xuweitao@wind-mobi.com 20180316
        copy_custom_files
    fi

    build_Project_Config
    #Lancelot -e

    ###################################################################
    #Start build
    ###################################################################
    echo "Build started `date +%Y%m%d_%H%M%S` ..."
    echo;echo;echo;echo

    source build/envsetup.sh
    if [ x$VARIANT == x"userroot" ] ; then
        lunch full_$PRODUCT-user
    else
        lunch full_$PRODUCT-$VARIANT
    fi
    ##source mbldenv.sh
    
    #lisonglin@wind-mobi.com source ./change_java.sh 1.7
    OUT_PATH=$WsRootDir/out/target/product/$PRODUCT
    case $ACTION in
        new | remake | clean)

        M=false; C=false;
        if [ x$ACTION == x"new" ];then M=true; C=true;
        elif [ x$ACTION == x"remake" ];then
          M=true;
          find $OUT_PATH/ -name 'build.prop' -exec rm -rf {} \;
        else C=true;
        fi

        case $MODULE in
            pl)
            if [ x$C == x"true" ];then clean_pl; result=$?; fi
            if [ x$M == x"true" ];then build_pl; result=$?; fi
            ;;

            k)
            if [ x$C == x"true" ];then clean_kernel; result=$?; fi
            if [ x$M == x"true" ];then
                build_kernel; result=$?
                if [ $result -eq 0 ];then make -j$CPUCORE bootimage-nodeps; result=$?; fi
            fi
            ;;

            lk)
            if [ x$C == x"true" ];then clean_lk; result=$?; fi
            if [ x$M == x"true" ];then build_lk; result=$?; fi
            ;;

            *)
            if [ x"$MODULE" == x"" ];then
                if [ x$C == x"true" ];then make clean; rm $LOG_PATH; fi
                if [ x$M == x"true" ];then
                    if [ x$VARIANT == x"userroot" ] ; then
                        echo "make userroot version"
                        make MTK_BUILD_ROOT=yes -j$CPUCORE 2>&1 | tee $LOG_PATH/build.log; result=$?;
                    else

                        #echo "lisonglin@wind-mobi.com make -j$CPUCORE 2>&1 | tee $LOG_PATH/build.log; result=$?;"
                        make -j$CPUCORE 2>&1 | tee $LOG_PATH/build.log; result=$?;
                    fi
                fi
            else
                echo  -e "\033[31m !!!!!!   No Such module ==$MODULE   !!!! \033[0m"
                exit 1
            fi
            ;;
        esac
        ;;

        mmma | mmm | m)
        $ACTION $MODULE 2>&1 | tee $LOG_PATH/$ACTION.log; result=$?
        ;;

        update-api | bootimage | systemimage | recoveryimage | userdataimage | cacheimage | snod | bootimage-nodeps | userdataimage-nodeps | ramdisk-nodeps | otapackage | otadiff | cts)        make -j$CPUCORE $ACTION 2>&1 | tee $LOG_PATH/$ACTION.log; result=$?
        ;;
    esac

    if [ $result -eq 0 ] && [ x$ACTION == x"mmma" -o x$ACTION == x"mmm" -o x$ACTION == x"m" ];then
        echo "Start to release module ...."
        DIR=`echo $MODULE | sed -e 's/:.*//' -e 's:/$::'`
        NAME=${DIR##*/}
        TARGET=out/target/product/${PRODUCT}/obj/APPS/${NAME}_intermediates/package.apk
        if [ -f $TARGET ];then
            cp -f $TARGET /data/mine/test/MT6572/${MY_NAME}/${NAME}.apk
        fi
    elif [ $result -eq 0 ] && [ $RELEASE_PARAM != "none" ]; then
        echo "Build completed `date +%Y%m%d_%H%M%S` ..."
        echo "Start to release version ...."
        echo "  lisonglin@wind-mobi.com  ${RELEASEPATH}     ${RELEASE_PARAM}"
        echo "Start to efuse version ...."
        build_efuse
        echo "finish to efuse version ...."
        ./release_version.sh ${RELEASEPATH} ${RELEASE_PARAM} efuse
    fi

}
#xuweitao@wind-mobi.com 20180621 start
function build_efuse()
{
        source build/envsetup.sh
        if [ x$VARIANT == x"userroot" ] ; then
            lunch full_$PRODUCT-user
        else
            lunch full_$PRODUCT-$VARIANT
        fi 
        ./vendor/mediatek/proprietary/scripts/sign-image/sign_image.sh;
        sleep 25;
}
#xuweitao@wind-mobi.com 20180621 end

function copy_custom_files()
{
    echo "Start custom copy files..."

    ./wind/scripts/copyfiles.pl $PRODUCT $BASE_PRJ

    echo "Copy custom files finish!"
}
#xuweitao@wind-mobi.com 20180316 start

function remove_mode_files()
{
	echo "Start remove mode files..."
    if [ -d $Mode_Path ];then
        rm -rf $Mode_Path
    fi 
	echo "Remove mode files finish!"
}
#xuweitao@wind-mobi.com 20180316 end
function export_Config
{
	while read line; do
		export $line
	done < ./version
	
    TIME=`date +%F`
    export RELEASE_TIME=$TIME
    export WIND_CPUCORES=$CPUCORE
	export WIND_PROJECT_NAME_CUSTOM=$PRODUCT
	export WIND_OPTR_NAME_CUSTOM=$PRODUCT
    export KERNEL_VER=alcatel-kernel
}

function build_Project_Config()
{
    ./wind/scripts/pjc.pl $PRODUCT

	export_Config

    #lisonglin@wind-mobi.com start
    #config_custom_audio_boot
	#lisonglin@wind-mobi.com end
}

#lisonglin@wind-mobi.com start
function config_custom_audio_boot()
{
    echo " XXXXXXXXX lisonglin@wind-mobi.com start config_custom_audio_boot "

    logoPath=`cat $WsRootDir/device/ginreen/$PRODUCT/ProjectConfig.mk | grep "BOOT_LOGO =" | awk -F = '{printf $2}' | sed s/[[:space:]]//g`

    if [ x$logoPath = x"" ];then 
        echo " generate logo failed logoPath=$logoPath== is null"
    else
        echo "lisonglin@wind-mobi.com  ===get project logo folder path success=====$logoPath======== "
    fi

    #copy prj overcopy folder
    cp -a $WsRootDir/device/ginreen/$PRODUCT/commonRes/overcopy/* ./
    
    if [ ! -d $WsRootDir/vendor/mediatek/proprietary/bootable/bootloader/lk/dev/logo/$logoPath/ ];then
        mkdir $WsRootDir/vendor/mediatek/proprietary/bootable/bootloader/lk/dev/logo/$logoPath/
    fi
   
    if [ -d $WsRootDir/device/ginreen/$PRODUCT/commonRes/boot/LOGO/$logoPath ];then
        cp -a $WsRootDir/device/ginreen/$PRODUCT/commonRes/boot/LOGO/$logoPath $WsRootDir/vendor/mediatek/proprietary/bootable/bootloader/lk/dev/logo/
    fi


    #copy boot anim and boot audio ,and system sounds config start
    cp -a $WsRootDir/device/ginreen/$PRODUCT/commonRes/boot/AllAudio.mk $WsRootDir/frameworks/base/data/sounds/AllAudio.mk

    #copy boot logo if exist
    cp -a $WsRootDir/device/ginreen/$PRODUCT/commonRes/boot/LOGO/${logoPath}_kernel.bmp $WsRootDir/vendor/mediatek/proprietary/bootable/bootloader/lk/dev/logo/$logoPath/
    cp -a $WsRootDir/device/ginreen/$PRODUCT/commonRes/boot/LOGO/${logoPath}_uboot.bmp $WsRootDir/vendor/mediatek/proprietary/bootable/bootloader/lk/dev/logo/$logoPath/
    
    cp -a $WsRootDir/device/ginreen/$PRODUCT/commonRes/boot/LOGO/cust_display.h $WsRootDir/vendor/mediatek/proprietary/bootable/bootloader/lk/target/$PRODUCT/include/target/

    if [ x$CUSTPRJ != x"commonRes" ];then 
        echo " XXXXXXXXX lisonglin@wind-mobi.com start config_custom_audio_boot copy custom logo "

        if [ -d $WsRootDir/device/ginreen/$PRODUCT/$CUSTPRJ/boot/LOGO/$logoPath ];then
            cp -a $WsRootDir/device/ginreen/$PRODUCT/$CUSTPRJ/boot/LOGO/$logoPath $WsRootDir/vendor/mediatek/proprietary/bootable/bootloader/lk/dev/logo/
        fi

        cp -a $WsRootDir/device/ginreen/$PRODUCT/$CUSTPRJ/overcopy/* ./
        cp -a $WsRootDir/device/ginreen/$PRODUCT/$CUSTPRJ/boot/AllAudio.mk $WsRootDir/frameworks/base/data/sounds/AllAudio.mk
        cp -a $WsRootDir/device/ginreen/$PRODUCT/$CUSTPRJ/boot/LOGO/${logoPath}_kernel.bmp $WsRootDir/vendor/mediatek/proprietary/bootable/bootloader/lk/dev/logo/$logoPath/
        cp -a $WsRootDir/device/ginreen/$PRODUCT/$CUSTPRJ/boot/LOGO/${logoPath}_uboot.bmp $WsRootDir/vendor/mediatek/proprietary/bootable/bootloader/lk/dev/logo/$logoPath/
        
        cp -a $WsRootDir/device/ginreen/$PRODUCT/$CUSTPRJ/boot/LOGO/cust_display.h $WsRootDir/vendor/mediatek/proprietary/bootable/bootloader/lk/target/$PRODUCT/include/target/

    fi
}
#lisonglin@wind-mobi.com end

#checkout disk space is gt 30G 
function Check_Space()
{
    UserHome=`pwd`
    Space=0
    Temp=`echo ${UserHome#*/}`
    Temp=`echo ${Temp%%/*}`
    ServerSpace=`df -lh $UserHome | grep "$Temp" | awk '{print $4}'`

    if echo $ServerSpace | grep -q 'G'; then
        Space=`echo ${ServerSpace%%G*}`
    elif echo $ServerSpace | grep -q 'T';then
        TSpace=1
    fi

    echo -e "\033[34m Log for Space $UserHome $ServerSpace $Space !!!\033[0m"
    if [ x"$TSpace" != x"1" ] ;then
        if [ "$Space" -le "30" ];then
            echo -e "\033[31m No Space!! Please Check!! \033[0m"
            exit 1
        fi
    fi
}

# check variant is or isn't the same as input 
function Check_Variant()
{
    buildProp=$WsRootDir/out/target/product/$PRODUCT/system/build.prop
    if [ -f $buildProp ] ; then
        buildType=`grep  ro.build.type $buildProp | cut -d "=" -f 2`
        if [ x$buildType != x"user" ] && [ x$buildType != x"userdebug" ]  && [ x$buildType != x"eng" ] ; then return; fi
        if [ x$VARIANT != x$buildType ]; then
            if [ x$ACTION == x"new" ]  ; then
                if [ x$MODULE == x"k" ] || [ x$MODULE == x"pl" ] || [ x$MODULE == x"lk" ] ; then
                    echo -e "\033[35mCode build type is\033[0m \033[31m$buildType\033[35m, your input type is\033[0m \033[31m$VARIANT\033[0m"
                    echo -e "\033[35mIf not correct, Please enter \033[31mCtrl+C\033[35m to Stop!!!\033[0m"
                    for i in $(seq 9|tac); do
                        echo -e "\033[34m\aLeft seconds:(${i})\033[0m"
                        sleep 1
                    done
                    echo
                fi
            else
                echo -e "\033[35mCode build type is\033[0m \033[31m$buildType\033[35m, your input type is\033[0m \033[31m$VARIANT\033[0m"
                echo -e "\033[35mChange build type to \033[31m$buildType\033[0m"
                echo
                VARIANT=$buildType
            fi
        fi
    else
        return;
    fi
}

main $1 $2 $3 $4 $5
