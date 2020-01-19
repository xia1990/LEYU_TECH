#!/usr/bin/python2
#_*_ coding:utf-8 _*_
#用来导wai0019修改点

import xlwt
import xlrd
import time
import commands
import re
import subprocess

project_name="^MT8167A_WAI016_PSW/.*"
date_today="2019-12-10"
branch="WAI0019_Main_BRH"

D_Time=time.strftime("%Y-%m-%d", time.localtime())
filename=commands.getoutput('ssh -p 29418 10.80.30.10 gerrit query branch:%s after:%s project:%s status:merged | grep "subject" > message.txt' % (branch,date_today,project_name))

commit_msg=[]


def set_style(name,height,bold=False):
    style=xlwt.XFStyle()
    pattern=xlwt.Pattern()
    pattern.pattern=xlwt.Pattern.SOLID_PATTERN
    #设置背景颜色
    pattern.pattern_fore_colour=7
    style.pattern=pattern
    #设置边框(为实线)
    borders=xlwt.Borders()
    borders.left=xlwt.Borders.THIN
    borders.right=xlwt.Borders.THIN
    borders.top=xlwt.Borders.THIN
    borders.bottom=xlwt.Borders.THIN
    style.borders=borders
    return style

def write_excel():
    
    f=xlwt.Workbook(encoding="utf-8")
    sheet1=f.add_sheet('修改点',cell_overwrite_ok=True)
    row0=[u'序号',u'BUG号',u'调试单元',u'软件确认状态',u'软件确认时间',u'备注']

    #第一行(表头内容)
    for i in range(0,len(row0)):
        sheet1.write(0,i,row0[i],set_style('Times New Roman',220,True))
		
    with open("message.txt","r") as f1:
        for line in f1.readlines():
            m1=re.split('\[Bug[a-zA-Z0-9\/\-\[\]\"\_\ ]*',line)
            #m2=re.split('subject\:[a-zA-Z0-9\/\-\[\]\"\_\ ]*\]',m1[0])
            #可以导出bug号
            m2=re.split('subject\:[a-zA-Z0-9\/\[\]\"\_\ ]*\]',m1[0])
            commit_msg.append(m2[1])
            for i in range(len(commit_msg)):
                #print(i)
                sheet1.write(i+1,0,i+1)
                sheet1.write(i+1,2,commit_msg[i])
                sheet1.write(i+1,3,"OK")
                sheet1.write(i+1,4,time.strftime("%Y%m%d"))
    f.save(time.strftime("%Y%m%d")+"修改问题点.xls")


if __name__=="__main__":
    write_excel()
    #read_excel()


