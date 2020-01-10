#!/bin/bash


ROOT_PATH=`pwd`
PROJECT=$1

function main(){
    cd $ROOT_PATH/
        rm -rf build_ota
        cp -rf ../build_ota .
        sleep 5
        if [ "$PROJECT" == "WAI0017_BLE_CENTRAL" ];then
            echo -e "\033[34m 从机用工程 \033[0m"
            cp -rf $PROJECT/examples/ble_central/ble_app_uart_c/pca10040/s132/arm5_no_packs/_build/*.hex ./build_ota/
            cp -rf $PROJECT/components/softdevice/s132/hex/*.hex ./build_ota/
            cp -rf WAI0017_BLE_DFU/examples/dfu/bootloader_serial/pca10040e/s132/arm5_no_packs/_build/*.hex ./build_ota/
        elif [ "$PROJECT" == "WAI0017_BLE_FROM" ];then
            echo -e "\033[34m 主机用工程 \033[0m"
            cp -rf WAI0017_BLE_DFU/examples/dfu/bootloader_serial/pca10040e/s132/arm5_no_packs/_build/*.hex ./build_ota/
            cp -rf $PROJECT/examples/ble_peripheral/ble_app_uarte/pca10040e/s132/arm5_no_packs/_build/*.hex ./build_ota/
            cp -rf $PROJECT/components/softdevice/s132/hex/*.hex ./build_ota/
        else
            echo -e "\033[31m 项目名称输入错误! \033[0m"
        fi
    cd -
}

if [ "$#" -ne 0 ];then
    main
else
    echo "请输入工程名称"
fi
