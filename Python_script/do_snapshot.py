#!/usr/bin/python
#_*_ coding:utf-8 _*_
#如果当前行是project,就打印它的name值,和分支名称


import xml.etree.ElementTree as ET
import os
import commands


pathroot=os.getcwd()

def do_snapshot():
    os.chdir(pathroot+"/.repo/manifests")
    os.getcwd
    tree=ET.parse("manifest.xml")
    root=tree.getroot()

    #得到fetch_name
    for origin in root.findall("remote"):
        fetch_name=origin.attrib['fetch']
		

    for child in root.findall("default"):
        #得到默认分支
        default_revision=child.attrib['revision']
        print default_revision

    #遍历所有project的行
    for project in root.iter("project"):
        #得到所有仓库名称
        project_name=project.attrib['name']
        #得到每个仓库的commitID
        commitID=commands.getoutput("git ls-remote %s%s -b %s | awk '{print $1}'" % (fetch_name,project_name,default_revision))
        #设置revision的值
        project.set("revision",commitID)
        #设置当前仓库名称
        project.set("upstream",default_revision)

    #在终端显示输出结果
    ET.dump(root)
    #写入xml文件
    tree.write("manifest.xml")


if __name__=="__main__":
    do_snapshot()
