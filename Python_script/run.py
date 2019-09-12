# coding:utf-8

from util.ob_util import *
import logging
import datetime

def weight_choice(list, weight):
    # 获取加权随机值
    new_list = []
    for i, val in enumerate(list):
        new_list.extend([val] * weight[i])

    return random.choice(new_list)


def run_cmd(cmd):
    p = subprocess.Popen(
        cmd,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT)

    for line in iter(p.stdout.readline, ''):
        logging.info(line.strip())

    p.wait()


class stability_test(object):
    # 文本日志配置
    logging.basicConfig(level=logging.DEBUG,
                        format='[%(asctime)s] [%(filename)s][line:%(lineno)d] [%(levelname)s] %(message)s',
                        filename='log/%s.log' % datetime.datetime.now().strftime('%Y-%m-%d'),
                        filemode='w')  # 文件写入模式，a为追加写入，w为重新写入

    # 控制台日志配置
    console = logging.StreamHandler()
    console.setLevel(logging.INFO)
    formatter = logging.Formatter('[%(asctime)s] [%(filename)s][line:%(lineno)d] [%(levelname)s] %(message)s')
    console.setFormatter(formatter)
    logging.getLogger('').addHandler(console)

    def __init__(self, device_id, logcat):
        self.d = OB(device_id, logcat)

        # 根据翻译机不同型号，判断对应业务版本是否在首页进行激活
        if self.d.model == 'S102X_32':
            self.d._obsetup()
        elif self.d.model == 'easytrans 800':
            self.d._fyj2setup()

        # 测试项目
        self.tests = tests
        self.weights = weights

    def tearDown(self):
        # 停止logcat日志
        if logcat:
            self.d.d.stop_logcat(self.d.logcat_pid, self.d.dmesg_pid)

    def test_longtime(self):
        # 稳定性测试
        for i in range(times):
            logging.info("Test Round {0}:".format(i + 1))
            getattr(self.d, weight_choice(self.tests, self.weights))()

    def test_BVT(self):
        # BVT测试
        self.d.run_BVT()

    def test_reset(self):
        # 长时间恢复出厂测试
        for i in range(times):
            logging.info("Test Round {0}:".format(i + 1))
            self.d.run_xxjReset()

    def test_reboot(self):
        # reboot
        for i in range(times):
            logging.info("Test Round {0}:".format(i + 1))
            self.d.run_monkey()
            self.d.run_reboot()

    def test_softsim(self):
        # 长时间softsim切卡测试
        for i in range(times):
            logging.info("Test Round {0}:".format(i + 1))
            self.d.run_softsim2()

    def test_camera(self):
        for i in range(times):
            logging.info("Test Round {0}:".format(i + 1))
            self.d.run_obcamera(compare_image=False)

    def test_ota(self):
        for i in range(times):
            logging.info("Test Round {0}:".format(i + 1))

            # 刷回老版本
            logging.info("Step 1: Begin QFIL Test.")
            self.d.run_qfil()

            # OTA 升级
            logging.info("Step 2: Begin OTA Test.")
            self.d.run_otaonline(connect_wifi=False, pull_system=False)

            # 恢复出厂
            logging.info("Step 3: Begin Reset Test.")
            self.d.run_obreset(pull_system=False)

    def test_ota2(self):
        for i in range(times):
            logging.info("Test Round {0}:".format(i + 1))

            # 刷回老版本
            logging.info("Step 1: Begin QFIL Test.")
            self.d.run_qfil2()

            # OTA 升级
            logging.info("Step 2: Begin OTA Test.")
            self.d.run_otaonline2(connect_wifi=True)

    def test_demo(self):
        pass

#from WifiTest import *
if __name__ == '__main__':

    # python -m uiautomator2 init
    #t = WIFITest('4ca4e985', 200, 'com.android.settings')
    #for i in random.sample(range(1, 8), 7):
     #   t.setUp()
      #  function = 'testCase0%s' % i
       # print(function)
        #getattr(t, function)()
        #t.tearDown()

    # *请根据需要配置
    device_id = ''  # adb devices id：当只有一个设备连接时，可为空；多个设备连接时，必须填写
    logcat = True  # 是否开启全局logcat日志
    times = 10000  # 测试次数

    # 运行测试名
    # test_BVT / test_longtime / test_reset / test_reboot / test_softsim / test_demo
    test_func = 'test_reboot'

    # 初始化测试类
    t = stability_test(device_id, logcat)
    # 运行测试
    getattr(t, test_func)()
    # 测试完成清理
    t.tearDown()

