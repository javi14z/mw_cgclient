from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
import time

def simulate_user():
    driver = webdriver.Firefox(executable_path="/root/geckodriver") # Use the appropriate driver
    driver.get("https://ia801802.us.archive.org/15/items/alexander-the-great-1997-part-1/Alexander%20The%20Great%20%281997%29%20Part%201.mp4")

    # Simulate the viewing
    time.sleep(3600)  # Let the video play for a while  
    driver.quit()

simulate_user()
