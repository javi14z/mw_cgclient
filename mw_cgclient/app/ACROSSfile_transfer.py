import os

def simulate_wget_download(url, save_path):
    command = f"wget {url} -O {save_path}"
    os.system(command)

video_url = "https://ia801802.us.archive.org/15/items/alexander-the-great-1997-part-1/Alexander%20The%20Great%20%281997%29%20Part%201.mp4"
save_path = "downloaded_video.mp4"
simulate_wget_download(video_url, save_path)