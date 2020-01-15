#!/usr/bin/python
#_*_ coding:utf-8 _*_

import os
import time

#需要备份的目录
source=['./script']
#备份到的目标目录
target_dir='./U_CODE/'
#压缩包的名称
target=target_dir+time.strftime("%Y%m%d%H%M%S")+".zip"
#压缩命令
zip_command="zip -qr -9 '%s' %s" % (target,' '.join(source))
if os.system(zip_command)==0:
    print("sucessful backupt o",target)
else:
    print("Backup FAILED")
