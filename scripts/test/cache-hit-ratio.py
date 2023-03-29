import requests

# Set variables for the test
base_url = "https://d25jryddpk2wfo.cloudfront.net"
test_resources = {
    "webpage": [
        "/index.html",
        "/404.html",
    ],
    "image": [f"/images/{i}.jpg" for i in range(1, 5)],
    "video": [f"/videos/{i}.mp4" for i in range(1, 5)],
    "docker-image": [
        "/docker-images/mysql-latest.tar",
        "/docker-images/alpine-latest.tar",
    ],
}
requests_count = 10


# Define a function to make a request and check if it was served from cache
def check_cache(response, cache_hits):
    if "Age" in response.headers:
        cache_hits += 1
        print("Cache hit!")
    else:
        print("Cache miss.")

    return cache_hits


# Make an initial request to ensure that the resource is cached
for resource_type, resource in test_resources.items():
    print(f"Testing {resource_type} resources...")
    for resource_url in resource:
        url = f"{base_url}{resource_url}"
        cache_hits = 0
        for i in range(requests_count):
            requests.get(url)
            response = requests.get(url)
            cache_hits = check_cache(response, cache_hits)

        # Calculate the cache hit ratio
        cache_hit_ratio = cache_hits / requests_count
        print(f"Cache hit ratio: {cache_hit_ratio:.2f}")


# Output the results
print("Test complete.")
print(f"Cache hit ratio: {cache_hit_ratio:.2f}")
