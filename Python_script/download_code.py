#!/usr/bin/python
#_*_ coding:utf-8 _*_
#下载代码脚本


import os
import commands
import xml.etree.ElementTree as ET


pathroot=os.getcwd()

def download_code():
    project_list=["S102X","M500N","P118F","P118F_Factory","S102X_SDM450","S102X_Factory","S102X_32","S102X_32_Factory","M500N_Factory","P118F_MP"]
    for project in project_list:
        if project=="M500N":
            M500N_URL="ssh://10.0.30.10:29418/LNX_SDM710_M500N_R10/Manifest"
            M500N_MIRROR="/EXCHANGE/mirror/AIBG_MIRROR/M500N_MIRROR_REPO/"
            BRANCH="PSW"
            code_url=M500N_URL
            code_mirror=M500N_MIRROR
        elif project=="P118F":
            P118F_URL="ssh://10.0.30.10:29418/LNX_LA_SDM450_PSW/Manifest"
            P118F_MIRROR="/EXCHANGE/mirror/AIBG_MIRROR/P118F_MIRROR_REPO/"
            BRANCH="master"
            code_url=P118F_URL
            code_mirror=code_mirror
        elif project=="P118F_Factory":
            P118F_Factory_URL="ssh://10.0.30.10:29418/LNX_LA_SDM450_PSW/Manifest"
            P118F_Factory_MIRROR="/EXCHANGE/mirror/AIBG_MIRROR/P118F_MIRROR_REPO/"
            BRANCH="Stable_P118F_Factory_BRH"
            code_url=P118F_Factory_URL
            code_mirror=P118F_Factory_MIRROR
        elif project=="P118F_MP":
            P118F_MP_URL="ssh://10.0.30.10:29418/LNX_LA_SDM450_PSW/Manifest"
            P118F_MP_MIRROR="/EXCHANGE/mirror/AIBG_MIRROR/P118F_MIRROR_REPO/"
            BRANCH="Stable_P118F_MP_BRH"
            code_url=P118F_MP_URL
            code_mirror=P118F_MP_MIRROR
        elif project=="S102X_32":
            S102X_32_URL="ssh://10.0.30.10:29418/LNX_LA_SDM450_S102X_PSW/Manifest"
            S102X_32_MIRROR="/EXCHANGE/mirror/AIBG_MIRROR/S102X_SDM450_MIRROR/"
            BRANCH="master_32"
            code_url=S102X_32_URL
            code_mirror=S102X_32_MIRROR
        elif project=="S102X_32_Factory":
            S102X_32_Factory_URL="ssh://10.0.30.10:29418/LNX_LA_SDM450_S102X_PSW/Manifest"
            S102X_32_Factory_MIRROR="/EXCHANGE/mirror/AIBG_MIRROR/S102X_SDM450_MIRROR/"
            BRANCH="Stable_Factory32_BRH"
            code_url=S102X_32_Factory_URL
            code_mirror=S102X_32_Factory_MIRROR

    #开始下载代码
    commands.getoutput("repo init -u %s  -m manifest.xml -b %s --reference=%s --repo-url=ssh://10.0.30.10:29418/Tools/Repo --no-repo-verify" %(code_url,BRANCH,code_mirror) )
    os.chdir(pathroot+"/.repo/manifests")
    tree=ET.parse("manifest.xml")
    root=tree.getroot()
    for child in root.findall("remote"):
        #修改XML中fetch的值
        child.attrib['fetch']="ssh://10.0.30.10:29418/"
        tree.write("manifest.xml")
    os.chdir(pathroot)
    commands.getoutput("repo sync -j4")
    commands.getoutput("repo start %s --all" % (BRANCH))
    

if __name__=="__main__":
    download_code()
