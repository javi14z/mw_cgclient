from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
import sys
import time
import pdb
import signal

def hang_handler(signum,frame):
	raise TimeoutException()

signal.signal(signal.SIGALRM, hang_handler)

#signal.alarm(300)

options = webdriver.ChromeOptions()
options.add_argument('headless')

browser = webdriver.Chrome(chrome_options=options)
#delay = float(sys.argv[2])
maxTimeWait = 120
browser.implicitly_wait(5)
browser.set_page_load_timeout(maxTimeWait)

try:
	#pdb.set_trace()
        browser.get(sys.argv[1])
	print("Visited page: " + browser.title + " (" + sys.argv[1] + ").")
	time.sleep(200)
	browser.get_screenshot_as_file('/home/cognet/' + str(int(time.time()))  + '.png')
        for i in range(1,3):
		time.sleep(60)
        	#browser.get_screenshot_as_file('/home/cognet/main-page%03d.png' % (i))
		browser.get_screenshot_as_file('/home/cognet/' + str(int(time.time())) + '.png')

except TimeoutException:
        browser.quit()
        sys.exit("The page is not responding (" + sys.argv[1] + ").")
except:
        browser.quit()
        sys.exit("Unexpected Error (" + sys.argv[1] + ").")
#time.sleep(delay)
browser.quit()
