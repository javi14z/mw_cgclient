from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
import time
import sys
import json
import os
import numpy


def simulate_user(duration, netlog_name):

    # Configuration
    options = Options()
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--log-net-log=' + netlog_name)
    options.set_capability('goog:loggingPrefs', {'performance': 'ALL', "browser": "ALL"})

    caps = DesiredCapabilities.CHROME
    caps['loggingPrefs'] = {'performance': 'ALL'}
    caps['pageLoadStrategy'] = 'normal'

    driver = webdriver.Chrome(executable_path="/root/chromedriver", options=options, desired_capabilities=caps, service_args=["--verbose", 
    f"--log-path=/home/cognet/chrome_logs/yt_driver.{os.path.basename(netlog_name)}.log"]) # Use the appropriate driver

    # Open youtube
    driver.get("https://www.youtube.com/watch?v=-No-226O0tg")

    # Accept cookies
    time.sleep(5)
    agree_button_xpath = "//*[@id=\"content\"]/div[2]/div[6]/div[1]/ytd-button-renderer[2]/yt-button-shape/button/yt-touch-feedback-shape/div/div[2]"
    agree_button = driver.find_element(By.XPATH, agree_button_xpath)
    agree_button.click()

    #Start video
    time.sleep(5)
    driver.find_element(By.TAG_NAME, 'body').send_keys("K")

    # Simulate the viewing for the specified duration
    time.sleep(duration)
    # Get the log
    log_performance = driver.get_log('performance')

    #Save log in .json
    with open('/home/cognet/chrome_logs/netlog.' + netlog_name +'.json', 'w') as log_file:
        for entry in log_performance:
            log_file.write(json.dumps(entry) + '\n')

    # last_known_url = None
    # request_headers_data = []
    # response_headers_data = []

    # for entry in log_performance:
    #     try:
    #         obj_serialized = entry.get("message")
    #         obj = json.loads(obj_serialized)
    #         message = obj.get("message")
    #         method = message.get("method")
    #         url = message.get("params", {}).get("documentURL")

    #         # Update last known URL if available
    #         if url:
    #             last_known_url = url

    #         if method == 'Network.requestWillBeSentExtraInfo' or method == 'Network.requestWillBeSent':
    #             try:
    #                 request_payload = message['params'].get('request', {})
    #                 request_headers = request_payload.get('headers', {})
    #                 # Store request headers and last known URL in request_headers_data
    #                 request_headers_data.append({"url": last_known_url, "headers": request_headers})
    #             except KeyError:
    #                 pass

    #         if method == 'Network.responseReceivedExtraInfo' or method == 'Network.responseReceived':
    #             try:
    #                 response_payload = message['params'].get('response', {})
    #                 response_headers = response_payload.get('headers', {})
    #                 # Store response headers and last known URL in response_headers_data
    #                 response_headers_data.append({"url": last_known_url, "headers": response_headers})
    #             except KeyError:
    #                 pass

    #         if method == 'Network.loadingFinished':
    #             # Network request is finished, you can now access request_headers_data and response_headers_data
    #             print("Request Headers:")
    #             for request_data in request_headers_data:
    #                 print("URL:", request_data["url"])
    #                 print(request_data["headers"])
    #             print("Response Headers:")
    #             for response_data in response_headers_data:
    #                 print("URL:", response_data["url"])
    #                 print(response_data["headers"])
    #             print('--------------------------------------')
    #     except Exception as e:
    #         raise e from None

    driver.quit()

#--------------------------------------------------------------------------------------------------

netlog_name = str(os.getpid()) + "_" + str(numpy.float64(time.time()))


if len(sys.argv) != 2:
    print("Usage: python3 ACROSSconsuming_video.py <duration>")
    exit(1)

try:
    duration = int(sys.argv[1])
    simulate_user(duration, netlog_name)
except ValueError:
    print("The argument value must be a valid integer.")
    exit(1)

