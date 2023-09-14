import socket
import time
import threading

def server_function():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind(("0.0.0.0", 8888))
    server_socket.listen(1)
    print("Server listening...")
    
    while True:
        client_socket, client_address = server_socket.accept()
        print(f"Connection from: {client_address}")
        threading.Thread(target=handle_client, args=(client_socket,)).start()

def handle_client(client_socket):
    # Simulate normal communication
    client_socket.send(b"Welcome to the server!\n")
    time.sleep(2)
    
    while True:
        data = client_socket.recv(1024)
        if not data:
            break
        print(data.decode())

    client_socket.close()

server_function()
