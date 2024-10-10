import os
import sys
import shutil
from datetime import datetime

start_dir = sys.argv[1]
end_dir = sys.argv[2]
start_date = sys.argv[3]
end_date = sys.argv[4]

start_date = datetime.strptime(start_date, "%Y-%m-%d")
end_date = datetime.strptime(end_date, "%Y-%m-%d")

if not os.path.exists(start_dir):
    print(f"Starting Directory: {start_dir} does not exist. Please pick a different directory.")
    sys.exit(1)
elif not os.path.exists(end_dir):
    print(f"Starting Directory: {start_dir} does not exist. Please pick a different directory.")
    sys.exit(1)

for filename in os.listdir(start_dir):
    file_path = os.path.join(start_dir, filename)

    if os.path.isfile(file_path):
        mod_time = datetime.fromtimestamp(os.path.getmtime(file_path))

        if start_date <= mod_time <= end_date:
            shutil.move(file_path, end_dir)

print("Files have been moved!")
