build_param=$1
release_param=$2
Efuse_param=$3

if [ x"$build_param" = "x" ];then
    echo "Usage: command [build_param]. e.g. ./release_version E200 xxxxx "
    exit 1
fi

if [ x"$release_param" = "x" ];then
   release_param=all
fi

ROOT=`pwd`
OUT_PATH=$ROOT"/out/target/product"
MY_NAME=`whoami`


#chenweida add CUSTOM_MODEM option 20150814 begin
OUT_PATH=$OUT_PATH/$build_param
BASE_PROJECT_NAME=$build_param
CUSTOM_MODEM=`cat ./device/ginreen/$build_param/ProjectConfig.mk | grep "^CUSTOM_MODEM" | tail -1 | sed "s/\s*CUSTOM_MODEM\s*=\s*\(.*\)\s*/\1/g"`
MODEM_LTG_PATH=$CUSTOM_MODEM
MODEM_LWG_PATH=$CUSTOM_MODEM
#echo "Hope MODEM_LTG_PATH = $MODEM_LTG_PATH"
#echo "Hope MODEM_LWG_PATH = $MODEM_LWG_PATH"


typeset -u PLATFORM
PLATFORM=`cat ./device/ginreen/$build_param/BoardConfig.mk | grep "^TARGET_BOARD_PLATFORM" | tail -1 | sed "s/\s*TARGET_BOARD_PLATFORM\s*:=\s*\(.*\)\s*/\1/g"`
echo "Hope PLATFORM = $PLATFORM"

HARDWARE_VER=`cat ./device/ginreen/$build_param/ProjectConfig.mk | grep "^MTK_CHIP_VER" | tail -1 | sed "s/\s*MTK_CHIP_VER\s*=\s*\(.*\)\s*/\1/g"`
echo "Hope HARDWARE_VER = $HARDWARE_VER"

MTK_BRANCH=`cat ./device/ginreen/$build_param/ProjectConfig.mk | grep "^MTK_BRANCH" | tail -1 | sed "s/\s*MTK_BRANCH\s*=\s*\(.*\)\s*/\1/g"`
echo "Hope MTK_BRANCH = $MTK_BRANCH"

MTK_WEEK_NO=`cat ./device/ginreen/$build_param/ProjectConfig.mk | grep "^MTK_WEEK_NO" | tail -1 | sed "s/\s*MTK_WEEK_NO\s*=\s*\(.*\)\s*/\1/g"`
echo "Hope MTK_WEEK_NO = $MTK_WEEK_NO"
#chenweida add CUSTOM_MODEM option 20150814 end


if [ ! -d $OUT_PATH ];then
    echo "ERROR: there is no out path:$OUT_PATH"
    exit 0
fi

if [ x"$release_param" = x"all" ]; then
#    if [ ! x"$MODEM_LTG_PATH" = "x" ];then
#        for i in "vendor/mediatek/proprietary/modem/$MODEM_LTG_PATH/BPLGUInfoCustomAppSrcP_MT6735_S00_MOLY_LR9*_ltg_n" ; do
#            if [ -f vendor/mediatek/proprietary/modem/$MODEM_LTG_PATH/BPLGUInfoCustomAppSrcP_MT6735_S00_MOLY_LR9*_ltg_n];then
 #                cp $i  $OUT_PATH/Modem_Database_ltg
#            fi
#        done
#    fi
#    if [ ! x"$MODEM_LWG_PATH" = "x" ];then
#        for i in "vendor/mediatek/proprietary/modem/$MODEM_LWG_PATH/BPLGUInfoCustomAppSrcP_MT6735_S00_MOLY_LR9*_lwg_n" ; do
#            if [ -f vendor/mediatek/proprietary/modem/$MODEM_LWG_PATH/BPLGUInfoCustomAppSrcP_MT6735_S00_MOLY_LR9*_lwg_n];then
 #                cp $i  $OUT_PATH/Modem_Database_lwg
#            fi
#        done
#    fi

    for i in "$OUT_PATH/obj/ETC/MDDB_InfoCustomAppSrcP_MT6750_S00_MOLY_LR11_*_1_ulwctg_n.EDB_intermediates/MDDB_InfoCustomAppSrcP_MT6750_S00_MOLY_LR11_*_1_ulwctg_n.EDB" ; do
    if [ -f $OUT_PATH/obj/ETC/MDDB_InfoCustomAppSrcP_MT6750_S00_MOLY_LR11_*_1_ulwctg_n.EDB_intermediates/MDDB_InfoCustomAppSrcP_MT6750_S00_MOLY_LR11_*_1_ulwctg_n.EDB ];then
        cp $i  $OUT_PATH/Modem_Database_ulwctg
    fi
    done
    echo "modem_ulwcrg"

#   for i in "$OUT_PATH/system/etc/mddb/BPLGUInfoCustomAppSrcP_MT6735_S00_MOLY_LR9*_ltg_n" ; do
#        if [ -f $i ]; then
#            cp $i  $OUT_PATH/Modem_Database_ltg
#        fi
#    done
#    for i in "$OUT_PATH/system/etc/mddb/BPLGUInfoCustomAppSrcP_MT6735_S00_MOLY_LR9*_lwg_n" ; do
#        if [ -f $i ]; then
#            cp $i  $OUT_PATH/Modem_Database_lwg
#        fi
#   done
#    for i in "$OUT_PATH/obj/ETC/boot_3_3g_n.rom_intermediates/boot_3_3g_n.rom" ; do
#        if [ -f $i ]; then
#            cp $i  $OUT_PATH/Modem_Database_c2k
#        fi
#    done


    cp "$OUT_PATH/obj/CGEN/APDB_MT6755_"$HARDWARE_VER"_"$MTK_BRANCH"_"$MTK_WEEK_NO"" /$OUT_PATH/AP_Database
    #for i in "$OUT_PATH/obj/CGEN/APDB_MT6755_S01_alps-mp-m0.mp7_W16.16" ; do
    #if [ -f $OUT_PATH/obj/CGEN/APDB_MT6755_S01_alps-mp-m0.mp7_W16.16 ];then
    #   cp $i  $OUT_PATH/AP_Database
    #fi
    #done
fi
#xuweitao@wind-mobi.com add Efuse option 20171218 begin
if [ x"$Efuse_param" == x"efuse" ];then 
    #xuweitao@wind-mobi.com delete some file 20180621 
    ALL_RELEASE_FILES="md1arm7-verified.img md1dsp-verified.img md1rom-verified.img md3rom-verified.img logo-verified.bin preloader_$BASE_PROJECT_NAME.bin AP_Database Modem_Database_ulwctg boot-verified.img secro.img userdata.img  system.img lk-verified.bin recovery-verified.img cache.img trustzone-verified.bin"
    case $release_param in
    all)
        RELEASE_FILES=$ALL_RELEASE_FILES
        ;;
    system)
        RELEASE_FILES="system.img"
        ;;
    boot)
        RELEASE_FILES="boot-verified.img"
        ;;
    lk)
        RELEASE_FILES="lk-verified.bin"
        ;;
    logo)
        RELEASE_FILES="logo-verified.bin"
        ;;
    userdata)
        RELEASE_FILES="userdata.img"
        ;;
    pl)
        RELEASE_FILES="preloader_$BASE_PROJECT_NAME.bin"
        ;;
    none)
        ;;
    *)
        echo "not supported!!"
        exit 1
        ;;
    esac
    else
#    ALL_RELEASE_FILES="logo.bin "$PLATFORM"_Android_scatter.txt preloader_$BASE_PROJECT_NAME.bin AP_Database Modem_Database_ltg boot.img secro.img userdata.img system.img lk.bin recovery.img cache.img trustzone.bin"#else
#    ALL_RELEASE_FILES="logo.bin MT6753_Android_scatter.txt preloader_$BASE_PROJECT_NAME.bin AP_Database Modem_Database_ulwtg Modem_Database_3g boot.img secro.img userdata.img system.img lk.bin recovery.img cache.img trustzone.bin"#fi
    #xuweitao@wind-mobi.com delete some file 20180621  
    ALL_RELEASE_FILES="md1arm7.img md1dsp.img md1rom.img md3rom.img logo.bin "$PLATFORM"_Android_scatter.txt preloader_$BASE_PROJECT_NAME.bin AP_Database Modem_Database_ulwctg boot.img secro.img userdata.img system.img lk.bin recovery.img cache.img trustzone.bin"
    case $release_param in
    all)
        RELEASE_FILES=$ALL_RELEASE_FILES
        ;;
    system)
        RELEASE_FILES="system.img"
        ;;
    boot)
        RELEASE_FILES="boot.img"
        ;;
    lk)
        RELEASE_FILES="lk.bin"
        ;;
    logo)
        RELEASE_FILES="logo.bin"
        ;;
    userdata)
        RELEASE_FILES="userdata.img"
        ;;
    pl)
        RELEASE_FILES="preloader_$BASE_PROJECT_NAME.bin"
        ;;
    none)
        ;;
    *)
        echo "not supported!!"
        exit 1
        ;;
    esac
fi
#xuweitao@wind-mobi.com add Efuse option 20171218 end
FILES=""
for file in $RELEASE_FILES; do
    echo "$file"
    FILES=$FILES" "$OUT_PATH"/"$file
done

if [ x"$RELEASE_FILES" != x"" ]; then
    if [ ! -f "$OUT_PATH/checklist.md5" ]; then
        echo "/*" >> $OUT_PATH/checklist.md5
        echo "* wind-mobi md5sum checklist" >> $OUT_PATH/checklist.md5
        echo "*/" >> $OUT_PATH/checklist.md5
    fi
    for file in $RELEASE_FILES; do
        if [ x"$target_files" != x"" ] && [ x"$file" == x"$target_files" ]; then
            cd $OUT_PATH/obj/PACKAGING/target_files_intermediates
        elif [ x"$file" == x"updateA2B.zip" ] || [ x"$file" == x"updateB2C.zip" ] ;then
            cd $ROOT
        elif [[ $file = *sign* ]];then
            cd $OUT_PATH/signed_bin/
        else
            cd $OUT_PATH
        fi
        md5=`md5sum -b $file`
        if [ -f "$OUT_PATH/checklist.md5" ]; then
            if [ x"$target_files" != x"" ] && [ x"$file" == x"$target_files" ] ;then
                line=`grep -n "\-target_files-" $OUT_PATH/checklist.md5 | cut -d ":" -f 1`
            elif [ x"$ota_files" != x"" ] && [ x"$file" == x"$ota_files" ] ;then
                line=`grep -n "\-ota-" $OUT_PATH/checklist.md5 | cut -d ":" -f 1`
            else
                line=`grep -n "$file" $OUT_PATH/checklist.md5 | cut -d ":" -f 1`
            fi
        fi
        if [ x"$line" != x"" ]; then
            sed -i $line's/.*/'"$md5"'/' $OUT_PATH/checklist.md5
        else
            if [ x"$md5" != x"" ];then
            echo "$md5" >> $OUT_PATH/checklist.md5
            fi
        fi
    done
    cd $ROOT
    if [ -f "$OUT_PATH/checklist.md5" ]; then
        FILES=$FILES" "$OUT_PATH"/"checklist.md5
    fi
fi

if [ -d $ROOT"/X100_out" ];then
    rm -rf $ROOT"/X100_out/"*
else
    mkdir $ROOT"/X100_out/"
fi 
    echo "start to copy those files to $ROOT/X100_out/"
if [ x"$Efuse_param" == x"efuse" ];then 
    cp $ROOT"/wind/scripts/MT6750_Android_scatter_efuse.txt" $ROOT"/X100_out/"
fi
    cp -rf $FILES $ROOT"/X100_out/"

echo "Sucess!"

