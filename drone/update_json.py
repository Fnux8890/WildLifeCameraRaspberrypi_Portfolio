import json
import sys
from datetime import datetime

def update_json(file_path):
    with open(file_path, 'r+') as f:
        data = json.load(f)
        data["Drone Copy"] = {
            "Drone ID": "WILDDRONE-001",
            "Seconds Epoch": int(datetime.now().timestamp())
        }
        f.seek(0)
        json.dump(data, f, indent=4)
        f.truncate()

if __name__ == "__main__":
    update_json(sys.argv[1])
