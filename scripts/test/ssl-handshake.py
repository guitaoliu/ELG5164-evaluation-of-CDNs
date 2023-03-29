import socket
import ssl
import time

# Set variables for the test
url = "d25jryddpk2wfo.cloudfront.net"
port = 443
requests_count = 100

# Initialize variables for calculating the average SSL handshake time
total_ssl_time = 0
average_ssl_time = 0


# Define a function to make a SSL request and measure the SSL handshake time
def make_ssl_request():
    start_time = time.time()
    # Create a socket and wrap it with SSL
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    ssl_sock = ssl.wrap_socket(sock, ssl_version=ssl.PROTOCOL_TLS)
    # Connect to the server and send a request
    ssl_sock.connect((url, port))
    ssl_sock.send(b"GET / HTTP/1.1\r\nHost: " + url.encode() + b"\r\n\r\n")
    # Receive the response and close the connection
    response = ssl_sock.recv(1024)
    ssl_sock.close()
    end_time = time.time()
    ssl_time = end_time - start_time
    print(f"SSL Handshake Time: {ssl_time * 1000:.4f} ms")
    return ssl_time


# Loop through the number of requests to be made
for i in range(requests_count):
    # Make the SSL request and measure the SSL handshake time
    ssl_time = make_ssl_request()
    total_ssl_time += ssl_time

# Calculate the average SSL handshake time
average_ssl_time = total_ssl_time / requests_count

# Output the results
print("Test complete.")
print(f"Average SSL handshake time: {average_ssl_time:.4f} s")
