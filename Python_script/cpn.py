#!/usr/bin/python


import os
import shutil
import getpass
import commands
import glob
import zipfile


base_path=os.getcwd()
user=getpass.getuser()
out=os.getcwd()+"/out"
overall_symbols=out+"/overall_symbols"

if os.path.isdir(out):
    shutil.rmtree(out)
os.makedirs(overall_symbols)
os.chdir(os.getcwd()+"/SDM450.LA.3.0.1/common/build")
commands.getoutput("python build.py")
os.chdir(base_path)

#NON-HLOS.bin
shutil.copy(os.getcwd()+"/SDM450.LA.3.0.1/common/build/bin/asic/NON-HLOS.bin",out)
#rpm.iimbn
shutil.copy(os.getcwd()+"/RPM.BF.2.4/rpm_proc/build/ms/bin/8953/rpm.mbn",out)
#prog_emmc_firehose_8917_lite.mbn
shutil.copy(os.getcwd()+"/BOOT.BF.3.3/boot_images/build/ms/bin/JAADANAZ/prog_emmc_firehose_8953_ddr.mbn",out)
#prog_emmc_firehose_8917_ddr.mbn
shutil.copy(os.getcwd()+"/BOOT.BF.3.3/boot_images/build/ms/bin/JAADANAZ/prog_emmc_firehose_8953_lite.mbn",out)
#sbl1.mbn
shutil.copy(os.getcwd()+"/BOOT.BF.3.3/boot_images/build/ms/bin/JAASANAZ/sbl1.mbn",out)
#adspso.bin  
shutil.copy(os.getcwd()+"/ADSP.8953.2.8.4/adsp_proc/build/dynamic_signed/8953/adspso.bin",out)
shutil.copy(os.getcwd()+"/../out/target/product/S102X_32/obj/KERNEL_OBJ/vmlinux",out)

#cmnlib.mbn  cmnlib64.mbn  devcfg.mbn  keymaster.mbn  
tz_list=["cmnlib.mbn", "cmnlib_30.mbn", "keymaster64.mbn", "cmnlib64.mbn", "cmnlib64_30.mbn", "devcfg.mbn", "keymaster.mbn"]
for i in tz_list:
    shutil.copy(os.getcwd()+"/TZ.BF.4.0.5/trustzone_images/build/ms/bin/SANAANAA/"+i,out)


#lksecapp.mbn
shutil.copy(os.getcwd()+"/TZ.BF.4.0.5/trustzone_images/build/ms/bin/SANAANAA/lksecapp.mbn",out)

#tz.mbn
shutil.copy(os.getcwd()+"/TZ.BF.4.0.5/trustzone_images/build/ms/bin/SANAANAA/tz.mbn",out)
#gpt_backup0.bin gpt_both0.bin gpt_main0.bin patch0.xml
gpt_list=["gpt_backup0.bin", "gpt_both0.bin", "gpt_main0.bin", "patch0.xml","rawprogram0.xml"]
for i in gpt_list:
    shutil.copy(os.getcwd()+"/SDM450.LA.3.0.1/common/build/"+i,out);
#emmc_appsboot.mbn boot.img recovery.img mdtp.img
ap_list=["emmc_appsboot.mbn", "boot.img", "mdtp.img", "recovery.img","splash.img","ramdisk-recovery.img"]
for i in ap_list:
    shutil.copy(os.getcwd()+"/../out/target/product/S102X_32/"+i,out)
#split img
path1=os.getcwd()+"/SDM450.LA.3.0.1/common/build/bin/asic/sparse_images/"
for i in os.listdir(path1):
    shutil.copy(os.getcwd()+"/SDM450.LA.3.0.1/common/build/bin/asic/sparse_images/"+i,out)

## fs_image.tar.gz.mbn.img
shutil.copy(os.getcwd()+"/fs_image.tar.gz.mbn.img",out)


##cp -rf --parents 
path4=os.getcwd()+"/ADSP.8953.2.8.4/adsp_proc/build/ms/"
list2=glob.glob(path4+"*.elf")
for i in list2:
    shutil.copy(i,overall_symbols)

shutil.copy(os.getcwd()+"/ADSP.8953.2.8.4/adsp_proc/qdsp6/qshrink/src/msg_hash.txt",overall_symbols)
##RPM
shutil.copy(os.getcwd()+"/RPM.BF.2.4/rpm_proc/core/bsp/rpm/build/8953/RPM_AAAAANAAR.elf",overall_symbols)
## TZ
shutil.copy(os.getcwd()+"/TZ.BF.4.0.5/trustzone_images/core/bsp/qsee/build/SANAANAA/qsee.elf",overall_symbols)
##MPSS
path2=os.getcwd()+"/MPSS.TA.2.3/modem_proc/build/myps/qshrink/"
for i in os.listdir(path2):
    shutil.copy(os.getcwd()+"/MPSS.TA.2.3/modem_proc/build/myps/qshrink/"+i,overall_symbols);
shutil.copy(os.getcwd()+"/MPSS.TA.2.3/modem_proc/build/ms/orig_MODEM_PROC_IMG_8953.gen.prodQ.elf",overall_symbols)
shutil.copy(os.getcwd()+"/MPSS.TA.2.3/modem_proc/build/ms/M89538953.gen.prodQ0000.elf",overall_symbols)

##CNSS.PR.4.0
path3=os.getcwd()+"/CNSS.PR.4.0/wcnss_proc/build/ms/"
list1=glob.glob(path3+"*.elf")
for i in list1:
    shutil.copy(i,overall_symbols)

shutil.copy(os.getcwd()+"/../out/target/product/S102X_32/factory.img",out)
shutil.copy(os.getcwd()+"/../out/target/product/S102X_32/esim.img",out)
shutil.copy(os.getcwd()+"/../out/target/product/S102X_32/useretc.img",out)

os.chdir(os.getcwd()+"/out")
shutil.copy("rawprogram_unsparse.xml","rawprogram_unsparse_upgrade.xml")
commands.getoutput("sed -i 's/factory_1.img//' rawprogram_unsparse_upgrade.xml")
commands.getoutput("sed -i 's/persist_1.img//' rawprogram_unsparse_upgrade.xml")
commands.getoutput("sed -i 's/esim_1.img//' rawprogram_unsparse_upgrade.xml")
commands.getoutput("mv rawprogram0.xml.bak rawprogram0_upgrade.xml")
commands.getoutput("sed -i 's/factory.img//' rawprogram0_upgrade.xml")
commands.getoutput("sed -i 's/esim.img//' rawprogram0_upgrade.xml")
commands.getoutput("sed -i 's/persist.img//' rawprogram0_upgrade.xml")

os.chdir(base_path+"/out")
path5="."
print(os.getcwd())
filename="FlashPackage_S102X_Master_QFIL.zip"
#z=zipfile.ZipFile(filename,"w",allowZip64=True,compression=zipfile.ZIP_DEFLATED)
z=shutil.make_archive("FlashPackage_S102X_Master_QFIL","zip",root_dir=".")

for root,dirs,filenames in os.walk(path5):
    if filenames:
        for filename in filenames:
            print("Adding...",filename)
            z.write(os.path.basename(root+os.path.sep+filename))
z.close()
#shutil.copy(filename,"/data/mine/test/MT6572/"+user)
