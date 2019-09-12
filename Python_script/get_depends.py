#!/usr/bin/python
import sys
import json
sys.setrecursionlimit(1500)  #设置最大递归深度1500
dd={}  #用来存放data.json里面的 字典
topList=[]  #用来存放找到的提交
with open('data.json') as jf:
	for line in jf.readlines():
		dd=json.loads(line)
		print dd
		

def getValue(key,topList):
	if key not in topList:  #如果这个提交不在toplist里面说明还没查过，如果存在就不要找了，防止死循环不停地查找，这里是递归出口
		topList.append(key) #添加到这个列表里
		result=dd.get(str(key),"error") #从字典中拿这个提交看看有没有(应该是有的，因为key就是从字典中得到的 dd.keys())
		if result == "error":
			print "error"
			pass
		else:
			if len(result) == 0: #如果拿到的key对应的是空列表就返回，这里是递归出口
				return
			else:
				for subkey in result: #如果列表不是空，说明有依赖，就继续调用函数查找依赖并添加到topList
					getValue(subkey,topList)
			return topList

for key in dd.keys(): #拿出字典里的 key，在字典中查找它是否有依赖
	getValue(key,topList)
	print topList
	
