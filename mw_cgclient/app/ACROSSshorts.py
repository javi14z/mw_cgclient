from selenium import webdriver
from selenium.webdriver.common.by import By
import time
import random
def simulate_cheetah_flow():

    driver = webdriver.Firefox(executable_path="/root/geckodriver")
    driver.get("https://www.youtube.com/shorts")

    # Accept cookies
    time.sleep(5)
    agree_button_xpath = "/html/body/c-wiz/div/div/div/div[2]/div[1]/div[3]/div[1]/form[2]/div/div/button/span"
    agree_button = driver.find_element(By.XPATH, agree_button_xpath)
    agree_button.click()
    time.sleep(5)

    #Click on scroll short
    while True:
        next_button_xpath = "/html/body/ytd-app/div[1]/ytd-page-manager/ytd-shorts/div[4]/div[2]/ytd-button-renderer/yt-button-shape/button/yt-touch-feedback-shape/div/div[2]"
        next_button = driver.find_element(By.XPATH, next_button_xpath)
        next_button.click()
        time.sleep(random.uniform(1.5, 5)) # Random interval between scrolls
        
simulate_cheetah_flow()