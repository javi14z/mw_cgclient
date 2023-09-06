import commands
import json
# import pdb
import signal
import sys
import time
import os
import numpy
from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

hang_timeout = 120


# close_connection_time=2

def hang_handler(signum, frame):
    raise TimeoutException()


def printDOM(log_performance):
    #	time.sleep(close_connection_time)

    final_time = numpy.float64(time.time())
    fich_dom_log = "dom_logs/dom_" + str(os.getpid()) + "_" + str(initial_time) + "_" + str(final_time) + ".txt"
    f = open(fich_dom_log, 'w')

    with open(netlog_name, 'r') as f2:
        netlog = json.load(f2)

    netlog_trimmed = []
    for event in netlog["events"]:
        toSave = False
        if "params" in event:
            if "url" in event["params"]:
                if (event["source"])["type"] == 1 and event["type"] == 2:
                    toSave = True
            if "source_dependency" in event["params"]:
                if event["type"] == 145:
                    toSave = True
                if event["type"] == 95:
                    toSave = True
            if "source_address" in event["params"]:
                toSave = True
        if toSave:
            netlog_trimmed.append(event)

    print >> f, ("#c_ip:1 s_ip:2 s_port:3 time_init:4 time_fin:5 petition_url:6 mimeType:7 url_dom:8")
    for entry in log_performance:
        message = entry["message"]
        message_dict = json.loads(message)
        message_dict2 = message_dict["message"]
        mdict = message_dict2["params"]

        if ("response" in mdict):
            response = mdict["response"]

            if "url" in response and "remoteIPAddress" in response and "remotePort" in response:
                url = str(response["url"])
                source_address = ""
                s_port = ""
                stop=False
		multi = False
                if (str(response["remoteIPAddress"]) != "") and (str(response["remotePort"]) != "0"):
                    for event in netlog_trimmed:
                        if "params" in event:
                            if "url" in event["params"]:
                                if (event["params"])["url"] == url and (event["source"])["type"] == 1 and event["type"] == 2:
                                    for event2 in netlog_trimmed:
                                        if "params" in event2:
                                            if "source_dependency" in event2["params"]:
                                                if event2["type"] == 145 and (event2["source"])["id"] == (event["source"])["id"]:
                                                    for event3 in netlog_trimmed:
                                                        if "params" in event3:
                                                            if "source_dependency" in event3["params"]:
                                                                if event3["type"] == 95 and (event3["source"])["id"] == ((event2["params"])["source_dependency"])["id"]:
                                                                    for event4 in netlog_trimmed:
                                                                        if "params" in event4:
                                                                            if "source_address" in event4["params"]:
                                                                                if event4["type"] == 35 and (event4["source"])["id"] == ((event3["params"])["source_dependency"])["id"]:
                                                                                    if stop:
                                                                                        multi = True
                                                                                    source_address = (event4["params"])["source_address"]
                                                                                    s_port = (source_address.split(":"))[1]
                                                                                    stop = True
                    if s_port != "" and not multi:
                        print >> f, (ip + " " + str(response["remoteIPAddress"]) + " " + str(response["remotePort"]) + " " +
                                     str(initial_time).replace(".", "") + " " + str(final_time).replace(".", "") + " " +
                                     str(sys.argv[1]) + " " + str(response["mimeType"]) + " " + url + " " + s_port)
                    else:
                        print >> f, (ip + " " + str(response["remoteIPAddress"]) + " " + str(response["remotePort"]) + " " +
                                str(initial_time).replace(".", "") + " " + str(final_time).replace(".", "") + " " +
                                str(sys.argv[1]) + " " + str(response["mimeType"]) + " " + url)

    f.close()


signal.signal(signal.SIGALRM, hang_handler)

signal.alarm(int(sys.argv[2]) + hang_timeout)

netlog_name = 'net_logs/netlog_' + str(os.getpid()) + "_" + str(numpy.float64(time.time()))

options = webdriver.ChromeOptions()
# options.add_argument('headless')
options.add_argument('--log-net-log=' + netlog_name)

caps = DesiredCapabilities.CHROME
caps['loggingPrefs'] = {'performance': 'ALL'}
caps['pageLoadStrategy'] = 'normal'

browser = webdriver.Chrome(chrome_options=options, desired_capabilities=caps)
maxTimeWait = int(sys.argv[2])
browser.implicitly_wait(5)
browser.set_page_load_timeout(maxTimeWait)

ip = commands.getoutput("echo $(ifconfig ens4) | cut -d ' ' -f7 | cut -d ':' -f2")

try:
    initial_time = numpy.float64(time.time())
    initial_time_video = time.time()
    browser.get(sys.argv[1])
    print("Visited page: " + browser.title + " (" + sys.argv[1] + ").")
    final_time_video = time.time()
    print str(int(sys.argv[2]) - int(final_time_video - initial_time_video))

except TimeoutException:
    log_performance = browser.get_log('performance')
    browser.quit()
    printDOM(log_performance)
    sys.exit("The page is not responding (" + sys.argv[1] + ").")

except Exception, e:
    log_performance = browser.get_log('performance')
    browser.quit()
    printDOM(log_performance)
    sys.exit("Unexpected Error (" + sys.argv[1] + ").\n" + str(e))

time.sleep(int(sys.argv[2]) - int(final_time_video - initial_time_video))
log_performance = browser.get_log('performance')
browser.quit()
printDOM(log_performance)
exit()
