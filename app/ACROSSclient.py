import socket
import time
import random

client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket.connect(("localhost", 8888))
response = client_socket.recv(1024)
print(response.decode())
multiplier = 10000 # Adjust the multiplier as needed
print(f"multiplier set to: {multiplier}")

while True:
    # Simulate cheetah flow burst
    if random.random() < 0.2: # Adjust the probability as needed
        cheetah_data = b"Cheetah burst data!\n" * (multiplier * random.randrange(0.5, 1.0)) # Generate a burst of data
        client_socket.send(cheetah_data)
        print("Cheetah flow burst sent.")
    time.sleep(random.uniform(0.5, 2)) # Random interval between bursts
client_socket.close()