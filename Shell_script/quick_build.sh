#!/bin/bash

CPUCORE=32
########################################
WsRootDir=`pwd`
LOG_PATH=$WsRootDir/build-log

PRODUCT=
PROJECT=
VARIANT=
ACTION=
NOHLOS_BUILD=
COPYFILES=
MODULE=
LOG_FILE=build.log
RADIO_PATH=$WsRootDir/device/qcom/SWAI_PAD/radio

########################## 宏控函数 end ##########################

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
   	echo "repo forall -c \"git checkout .\""
   	repo forall -c "git checkout ."
   	echo "rm -rf $LOG_PATH/*"
   	rm -rf $LOG_PATH/*
   	echo "rm -rf out"
   	rm -rf out
   	echo -e "\033[33mComplete revert code.\033[0m"
   	exit 0
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

function build_version()
{
    echo "********remove old version********"
    if [ -f "./version" ] ;then
       rm version
    fi

    VERSION=$WsRootDir/device/qcom/${PRODUCT}/version
    if [ -f "$VERSION" ] ;then
       echo "***************copy new version***************"
       cp $VERSION .
       echo
    else
       echo "File version not exist!!!!!!!!!"
    fi
    INVER=`awk -F = 'NR==1 {printf $2}' version`
    OUTVER=`awk -F = 'NR==2 {printf $2}' version`
    HARDWAREVER=`awk -F = 'NR==3 {printf $2}' version`
    export VER_INNER=$INVER
    export VER_OUTER=$OUTVER
    export VER_HW=$HARDWAREVER
}

function copy_custom_files()
{
    echo "Start copy custom files..."
    cp -rf ./wind/custom_files/* .
    cp -rf ./wind/custom_files/build/core/* build/core/
    cp -rf ./wind/custom_files/build/tools/* build/tools/
    cp -rf ./wind/custom_files/build/target/* build/target/
    echo "Copy custom files finish!"
}

function analyze_args()
{
    ### set PRODUCT
    PROJECT=$1
    case $PROJECT in
        SWAI_PAD)
        PRODUCT=SWAI_PAD
        echo "PRODUCT=$PRODUCT"
        ;;
        *)
        echo "PRODUCT name error [$PROJECT]!!!"
        exit 1
        ;;
    esac

    command_array=($2 $3 $4 $5 $6)

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
        elif [ x$command == x"m" ] || [ x$command == x"make" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=m
        elif [ x$command == x"revert" ] ;then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=revert
        elif [ x$command == x"mmma" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=mmma
        elif [ x$command == x"mmm" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=mmm
        elif [ x$command == x"api" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=update-api
        elif [ x$command == x"boot" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=bootimage
        elif [ x$command == x"system" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=systemimage
        elif [ x$command == x"userdata" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=userdataimage
        elif [ x$command == x"boot-nodeps" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=bootimage-nodeps
        elif [ x$command == x"snod" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=snod
        elif [ x$command == x"userdata-nodeps" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=userdataimage-nodeps
        elif [ x$command == x"ramdisk-nodeps" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=ramdisk-nodeps
        elif [ x$command == x"recovery" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=recoveryimage
        elif [ x$command == x"cache" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=cacheimage
        elif [ x$command == x"otapackage" ] || [ x$command == x"ota" ] ;then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=otapackage
        elif [ x$command == x"otadiff" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=otadiff
        elif [ x$command == x"cts" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=cts
        
	elif [ x$command == x"nohlos" ] || [ x$command == x"NOHLOS" ];then
            if [ x$NOHLOS_BUILD != x"" ];then continue; fi
            NOHLOS_BUILD=NOHLOS
	elif [ x$command == x"MPSS" ];then
            if [ x$NOHLOS_BUILD != x"" ];then continue; fi
            NOHLOS_BUILD=MPSS
	elif [ x$command == x"BOOT" ];then
            if [ x$NOHLOS_BUILD != x"" ];then continue; fi
            NOHLOS_BUILD=BOOT
	elif [ x$command == x"TZ" ];then
            if [ x$NOHLOS_BUILD != x"" ];then continue; fi
            NOHLOS_BUILD=TZ
	elif [ x$command == x"RPM" ];then
            if [ x$NOHLOS_BUILD != x"" ];then continue; fi
            NOHLOS_BUILD=RPM
	elif [ x$command == x"ADSP" ];then
            if [ x$NOHLOS_BUILD != x"" ];then continue; fi
            NOHLOS_BUILD=ADSP
		
        ### set COPYFILES
        elif [ x$command == x"fc" ];then
            if [ x$COPYFILES != x"" ];then continue; fi
            COPYFILES=yes
        elif [ x$command == x"nc" ];then
            if [ x$COPYFILES != x"yes" ];then continue; fi
            COPYFILES=no
			
        ### set MODULE
        elif [ x$command == x"pl" ];then
            if [ x$MODULE != x"" ];then continue; fi
            MODULE=pl
        elif [ x$command == x"k" ] || [ x$command == x"kernel" ];then
            if [ x$MODULE != x"" ];then continue; fi
            MODULE=k
        elif [ x$command == x"ab" ];then
            if [ x$MODULE != x"" ];then continue; fi
            MODULE=ab

        else
            if [ x$MODULE != x"" ];then continue; fi
            MODULE=$command
        fi
    done

    if [ x$PRODUCT == x"" ] && [ x$NOHLOS_BUILD = x"" ];then
        echo "ERROR:not find PRODUCT"
        usage
        exit 1
    fi

    if [ x$ACTION == x"" ]&& [ x$NOHLOS_BUILD = x"" ];then
        echo "ERROR:not find ACTION"
        usage
        exit 1
    fi

    #设置默认值
    if [ x$VARIANT == x"" ] && [ x$NOHLOS_BUILD = x"" ];then VARIANT=userdebug; fi
    if [ x$ACTION == x"" ] && [ x$NOHLOS_BUILD = x"" ];then ACTION=remake; fi
    if [ x$COPYFILES == x"" ] && [ x$NOHLOS_BUILD = x"" ];then COPYFILES=no; fi
}

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

#编译OTA包，make otapackage 
function makeOta()
{
    echo "start to make otapackage"
    cd $WsRootDir/out/target/product/$PRODUCT/
    	cp emmc_appsboot.mbn mdtp.img $RADIO_PATH
    cd -
    source build/envsetup.sh
    if [ x$VARIANT == x"userroot" ] ; then
        lunch $PRODUCT-user
    else
        lunch $PRODUCT-$VARIANT
		echo "lunch end"
    fi
    make otapackage
}

function main()
{
    ##################################################################
    #Check parameters
    ##################################################################
    if [ ! -d $LOG_PATH ];then
        mkdir $LOG_PATH
    fi


    if [ x$1 == x"x" ] || [ x$1 == x"-help" ] ;then
        usage
        exit 1
    fi

    analyze_args $1 $2 $3 $4 $5 $6
    echo "`date +"%F %T"` ./quick_build.sh $1 $2 $3 $4 $5 $6" > $LOG_PATH/record.log

    if [ x$ACTION == x"revert" ];then
        revert_code
    fi

    ### Check VARIANT WHEN NOT NEW
    Check_Variant

    echo "PRODUCT=$PRODUCT VARIANT=$VARIANT ACTION=$ACTION MODULE=$MODULE COPYFILES=$COPYFILES ORIGINAL=$ORIGINAL WIND_SWAI_PAD_FACTORY=$WIND_SWAI_PAD_FACTORY"
    echo "Log Path $LOG_PATH"

    ##################################################################
    #Prepare
    ##################################################################
    Check_Space

    if [ x$COPYFILES == x"yes" ];then
        copy_custom_files
    fi
    
    build_version
    
    ###################################################################
    #Start build
    ###################################################################
    echo "Build started `date +%Y%m%d_%H%M%S` ..."
    echo;echo;echo;echo
	
    if [ x$NOHLOS_BUILD == x"NOHLOS" ] ; then
    	echo "NOHLOS Build started `date +%Y%m%d_%H%M%S` ..."
		echo
		echo "开始编译N侧 $NOHLOS_BUILD "
		
		cd ./NOHLOS
			./build_n.sh all
		cd -
		
	elif [ x$NOHLOS_BUILD == x"MPSS" ] || [ x$NOHLOS_BUILD == x"BOOT" ] || [ x$NOHLOS_BUILD == x"TZ" ] || [ x$NOHLOS_BUILD == x"RPM" ] || [ x$NOHLOS_BUILD == x"ADSP" ] ;then
		echo "NOHLOS Build started `date +%Y%m%d_%H%M%S` ..."
		echo
		echo "开始编译N侧 $NOHLOS_BUILD"
		
		cd ./NOHLOS
			./build_n.sh $NOHLOS_BUILD
		cd -
    else
        echo "编译完成"
	fi	


    #lunch $PRODUCT-$VARIANT
    if [ x$VARIANT == x"userroot" ] ; then
		source build/envsetup.sh
        lunch $PRODUCT-user
    else
		source build/envsetup.sh
        lunch $PRODUCT-$VARIANT
    fi

    OUT_PATH=$WsRootDir/out/target/product/$PRODUCT
    case $ACTION in
        new)
        make clean
        make -j $CPUCORE 2>&1 | tee $LOG_PATH/$LOG_FILE
        ;;
        remake)
        make -j $CPUCORE 2>&1 | tee $LOG_PATH/$LOG_FILE
        ;;

        mmma | mmm | m)
        $ACTION $MODULE 2>&1 | tee $LOG_PATH/$ACTION.log; result=$?
        ;;

        update-api | bootimage | systemimage | recoveryimage | userdataimage | cacheimage | snod | bootimage-nodeps | userdataimage-nodeps | ramdisk-nodeps | otapackage | otadiff | cts)
        make -j$CPUCORE $ACTION 2>&1 | tee $LOG_PATH/$ACTION.log; result=$?
        ;;
    esac

    echo "Build completed `date +%Y%m%d_%H%M%S` ..."
    echo "If you want to release version , please use release_version.sh"
	
	echo "Begin execute cpn script!"
	echo
	if [ x$NOHLOS_BUILD == x"NOHLOS" ] ; then
		cd ./NOHLOS
			./cpn
		cd -
		### if compile MPSS then call cpn_NOHLOS release MPSS & symbols only
	elif [ x$NOHLOS_BUILD == x"MPSS" ];then
			./cpn_NOHLOS
    else
        echo "编译完成"
	fi	
}

usage() {
cat <<USAGE

Usage:
    bash_path$ $0 [PRODUCT] [ACTION] [VARIANT] [COPYFILES] [NOHLOS_BUILD]
    e.g : bash_path$ $0 S100X r debug fc wud

PRODUCT:
    SWAI

ACTION:
    new | remake | n | r | boot | system | userdata 
	
NOHLOS_BUILD:
    nohlos | NOHLOS

VARIANT:
    user | debug | eng

COPYFILES:
    nc | fc


用法：
    bash_path$ $0 [PRODUCT] [ACTION] [VARIANT] [COPYFILES] [NOHLOS_BUILD]
    示例: bash_path$ $0 SWAI_PAD r debug fc （remake debug版本 copy wind目录）

PRODUCT:
    SWAI

ACTION:
    new | remake | n | r | boot | system | userdata

NOHLOS_BUILD:
    nohlos | NOHLOS
	
VARIANT:
    user | debug | eng

COPYFILES:
    nc | fc （不copy wind目录 | copy wind目录）

USAGE
}

main $1 $2 $3 $4 $5 $6
