from selenium import webdriver
import time
import random
def simulate_cheetah_flow():

    driver = webdriver.Firefox(executable_path="/root/geckodriver")
    driver.get("https://www.tiktok.com/es/")
    
    while True:
        driver.execute_script("window.scrollBy(0, 1000);") # Adjust the amount of pixels to scroll vertically in order to skip to the next video in the feed
        time.sleep(random.uniform(0.5, 2)) # Random interval between scrolls
        
simulate_cheetah_flow()