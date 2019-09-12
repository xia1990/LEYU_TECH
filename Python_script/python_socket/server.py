#!/usr/bin/python
#_*_ coding:utf-8 _*_


import socket
import sys
reload(sys)
sys.setdefaultencoding("utf-8")

server=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
server.bind(("localhost",9090))
server.listen(5)
while True:
    conn,addr=server.accept()
    print(conn,addr)
    while True:
        data=conn.recv(1024)
        print('recive:',data.decode())
        conn.send(data.upper())
    conn.close()
