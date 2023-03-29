import requests

# Set variables for the test
url = "https://d25jryddpk2wfo.cloudfront.net"
requests_count = 100

# Initialize variables for calculating the error rate
error_count = 0

# Loop through the number of requests to be made
for i in range(requests_count):
    # Make the request and check for an error response
    response = requests.get(url)
    if response.status_code >= 400:
        error_count += 1
    print(f"Request {i+1}: HTTP status code {response.status_code}")

# Calculate the error rate
error_rate = error_count / requests_count

# Output the results
print("Test complete.")
print(f"Error rate: {error_rate:.2f}")
