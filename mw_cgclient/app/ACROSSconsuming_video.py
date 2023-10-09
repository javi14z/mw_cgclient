from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.options import Options
import time

def simulate_user():

    options = Options()
    options.headless = True

    driver = webdriver.Firefox(executable_path="/root/geckodriver", options=options) # Use the appropriate driver
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

    # Simulate the viewing
    time.sleep(3600)  # Let the video play for a while  
    driver.quit()

simulate_user()
