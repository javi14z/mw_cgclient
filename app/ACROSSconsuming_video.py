from selenium import webdriver
import time

def simulate_user(browser_number):
    driver = webdriver.Chrome() # Use the appropriate driver
    driver.get("https://www.youtube.com/watch?v=MCWytnIJfc4d")
    #Simulate the viewing
    time.sleep(3600) # Let the video play for a while
    driver.quit()