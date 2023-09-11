from selenium import webdriver
import time
import random
def simulate_cheetah_flow():
    chrome_options = webdriver.ChromeOptions()
    chrome_options.binary_location = '/usr/bin/chromium-browser'
    chrome_options.add_argument('--headless')  # Opcional: para ejecución sin cabeza
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-dev-shm-usage')

    driver = webdriver.Chrome('/usr/lib/chromium-browser/chromedriver', options=chrome_options)
    driver.get("https://www.youtube.com/shorts")
    
    while True:
        driver.execute_script("window.scrollBy(0, 1000);") # Adjust the amount of pixels to scroll vertically in order to skip to the next video in the feed
        time.sleep(random.uniform(0.5, 2)) # Random interval between scrolls
simulate_cheetah_flow()