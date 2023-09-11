from selenium import webdriver
import time

def simulate_user():
    driver = webdriver.Chrome('/usr/bin/chromium-browser')
    driver.get("https://www.youtube.com/watch?v=MCWytnIJfc4d")
    # Simula la visualización
    time.sleep(3600)  # Deja que el video se reproduzca durante un tiempo
    driver.quit()

simulate_user()
