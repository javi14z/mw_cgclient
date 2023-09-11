import os

def simulate_wget_download(url, save_path):
    command = f"wget {url} -O {save_path}"
    os.system(command)

video_url = "https://www.youtube.com/watch?v=MCWytnIJfc4"
save_path = "downloaded_video.mp4"
simulate_wget_download(video_url, save_path)