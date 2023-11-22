from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from selenium.webdriver.common.keys import Keys
import sys
import json
import os
import numpy
import time
import random

def simulate_cheetah_flow(duration, netlog_name):

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
    f"--log-path=/home/cognet/logs/short_driver.{os.path.basename(netlog_name)}.log"]) # Use the appropriate driver

    try:
        driver.get("https://www.youtube.com/shorts")

        # Accept cookies
        time.sleep(5)
        agree_button_xpath = "/html/body/c-wiz/div/div/div/div[2]/div[1]/div[3]/div[1]/form[2]/div/div/button/span"
        agree_button = driver.find_element(By.XPATH, agree_button_xpath)
        agree_button.click()
        time.sleep(5)

        print("Simulating viwing...")
        start_time = time.time()
        #Scroll short
        while  time.time() - start_time < duration:
            driver.find_element(By.TAG_NAME, 'body').send_keys(Keys.ARROW_DOWN)
            time.sleep(random.uniform(1.5, 5)) # Random interval between scrolls

        # Get the log
        log_performance = driver.get_log('performance')
    finally:
        print("Closing Chrome driver...")
        # Close the driver in the finally block to ensure it is always closed
        driver.quit()

        print("Saving log in .json...")
        #Save log in .json
        with open('/home/cognet/logs/short_netlog.' + netlog_name +'.json', 'w') as log_file:
            for entry in log_performance:
                log_file.write(json.dumps(entry) + '\n')


netlog_name = str(os.getpid()) + "_" + str(numpy.float64(time.time()))


if len(sys.argv) != 2:
    print("Usage: python3 ACROSSACROSSshorts.py <duration>")
    exit(1)

try:
    duration = int(sys.argv[1])
    simulate_cheetah_flow(duration, netlog_name)
except ValueError:
    print("The argument value must be a valid integer.")
    exit(1)