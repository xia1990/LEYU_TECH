#!/usr/bin/python
class gaolaoha(object):
	def __init__(self):
		self.firstname='laoha'
		self.lastname='gao'
	
	def zhongxianggu(self):
		print '%s %s can zhongxianggu' % (self.lastname,self.firstname)
		
class gaoyuxia(gaolaoha):
	def __init__(self):
		gaolaoha.__init__(self)
		self.firstname='yuxia'
		
	def build_job(self):
		print '%s %s can build job' % (self.lastname,self.firstname)
		
if __name__ == "__main__":
	xiaogao=gaoyuxia()
	print xiaogao.lastname
	print xiaogao.firstname
	xiaogao.build_job()
	xiaogao.zhongxianggu()
