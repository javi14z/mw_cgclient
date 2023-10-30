import socket
import time
import random
import os
import sys

# Obtén la dirección IP del servidor desde la variable de entorno
cgserver_ip = os.getenv("cgserver")

if cgserver_ip is None:
    print("An IP address was not provided for the server. Make sure to set the cgserver environment variable. Run export cgserver=¨ip¨")
    exit(1)

if len(sys.argv) != 2:
    print("Usage: python3 ACROSSclient.py <multiplier>")
    exit(1)

try:
    multiplier = int(sys.argv[1])
except ValueError:
    print("The argument value must be a valid integer.")
    exit(1)

client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket.connect((cgserver_ip, 8888))

response = client_socket.recv(1024)
print(response.decode())


print(f"multiplier set to: {multiplier}")

while True:
    # Simulate cheetah flow burst
    if random.random() < 0.2:  # Adjust the probability as needed
        cheetah_data = b"Cheetah burst data!\n" * int(multiplier * random.uniform(0.5, 1.0))  # Generate a burst of data
        client_socket.send(cheetah_data)
        print("Cheetah flow burst sent.")
    time.sleep(random.uniform(0.5, 2))  # Random interval between burst
client_socket.close()
