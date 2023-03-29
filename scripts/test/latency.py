#!/usr/bin/env python3

import asyncio
import aiohttp

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

concurrency = 10
requests_count = 20

total_timings = 0
lock = asyncio.Lock()


# Define an async function to make requests
async def make_request(session, url):
    start = asyncio.get_event_loop().time()
    async with session.get(url) as response:
        response_time = round((asyncio.get_event_loop().time() - start) * 1000, 4)
        async with lock:
            global total_timings
            total_timings += response_time
        print(f"{url} response time {response.status}: {response_time} ms")
        return response_time


# Define the main async function
async def main():
    average_timings_map = {}
    for resource_type, resource in test_resources.items():
        # Create an aiohttp session and a list to store the tasks
        async with aiohttp.ClientSession() as session:
            print(f"Testing {resource_type} resources...")
            average_timings = 0
            for resource_url in resource:
                tasks = []
                # Add the tasks to the list
                for i in range(requests_count):
                    task = asyncio.create_task(
                        make_request(session, f"{base_url}{resource_url}")
                    )
                    tasks.append(task)
                    # If the number of concurrent requests has been reached, wait for them to finish before making more requests
                    if i % concurrency == concurrency - 1:
                        await asyncio.gather(*tasks)
                        tasks = []
                # Wait for any remaining tasks to finish
                if tasks:
                    await asyncio.gather(*tasks)

                global total_timings
                average_timings += total_timings / requests_count
                async with lock:
                    total_timings = 0
            average_timings = round(average_timings / len(resource), 4)
            print(f"{resource_type} average response time: {average_timings} ms")
            average_timings_map[resource_type] = average_timings

    print("Average response times:")
    for resource_type, average_timings in average_timings_map.items():
        print(f"{resource_type}: {average_timings} ms")


# Run the main async function
asyncio.run(main())

# Output the results
print("Test complete.")
