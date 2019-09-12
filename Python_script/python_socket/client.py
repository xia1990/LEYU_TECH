#!/usr/bin/python
#_*_ coding:utf-8 _*_


import socket
import sys
reload(sys)
sys.setdefaultencoding("utf-8")


client=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
client.connect(("localhost",9090))
while True:
    msg="欢迎菜鸟教程！"
    client.send(msg.encode("utf-8"))
    data=client.recv(1024)
    print('recv:',data.decode())
client.close()
