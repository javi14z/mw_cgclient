from selenium import webdriver
import time

def simulate_user():
    driver = webdriver.Firefox(executable_path="/root/geckodriver")
    driver.get("https://ia801802.us.archive.org/15/items/alexander-the-great-1997-part-1/Alexander%20The%20Great%20%281997%29%20Part%201.mp4")
    # Simula la visualización
    time.sleep(3600)  # Deja que el video se reproduzca durante un tiempo
    driver.quit()

simulate_user()
