from selenium import webdriver
import time

def simulate_user():
    chrome_options = webdriver.ChromeOptions()
    chrome_options.binary_location = '/usr/bin/chromium-browser'
    chrome_options.add_argument('--headless')  # Opcional: para ejecución sin cabeza
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-dev-shm-usage')

    driver = webdriver.Chrome('/usr/lib/chromium-browser/chromedriver', options=chrome_options)
    driver.get("https://www.youtube.com/watch?v=MCWytnIJfc4d")
    # Simula la visualización
    time.sleep(3600)  # Deja que el video se reproduzca durante un tiempo
    driver.quit()

simulate_user()
