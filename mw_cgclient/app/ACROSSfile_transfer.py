import os
import sys

def simulate_wget_download(url, save_path):
    command = f"wget {url} -O {save_path} -o /home/cognet/chrome_logs/file_transfer.log"
    os.system(command)

save_path = "file_transfer.mp4"

if len(sys.argv) != 2:
    print("Usage: python3 ACROSSfile_transfer.py <URL>")
    exit(1)

try:
    video_url = sys.argv[1]
    simulate_wget_download(video_url, save_path)
except ValueError:
    print("The argument value must be a valid integer.")
    exit(1)
