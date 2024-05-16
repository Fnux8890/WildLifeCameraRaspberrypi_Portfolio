import sys
import json
import os
from datetime import datetime
import ollama  


def pull_model(model_name):
    try:
        ollama.pull(model_name)
        print(f"Model {model_name} successfully pulled.")
    except Exception as e:
        print(f"Failed to pull model {model_name}: {e}")

def describe_image(image_path):
    """ Use the Ollama model to describe the image. """
    res = ollama.chat(
        model="llava",
        messages=[{'role': 'user', 'content': 'Describe this image:', 'images': [image_path]}]
    )
    return res['message']['content']

def update_json_metadata(image_path, description, output_directory):
    """ Update JSON metadata with image description and save it to a new location. """
    # Original JSON path
    original_json_path = image_path.replace('.jpg', '.json')
    # New JSON path in the output directory
    new_json_path = os.path.join(output_directory, os.path.basename(original_json_path))

    if os.path.exists(original_json_path):
        with open(original_json_path, 'r') as f:
            data = json.load(f)
        
        # Add or update the description and processed timestamp
        data["Description"] = description
        data["Processed Timestamp"] = int(datetime.now().timestamp())

        # Save updated data to the new location
        with open(new_json_path, 'w') as f:
            json.dump(data, f, indent=4)

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python update_images.py <image_path> <output_directory> <records_path>")
        sys.exit(1)
        
        
	
    image_path = sys.argv[1]
    output_directory = sys.argv[2]
    records_path = sys.argv[3]  

    # Ensure output directory exists
    if not os.path.exists(output_directory):
        os.makedirs(output_directory)

    pull_model("llava")
    description = describe_image(image_path)
    update_json_metadata(image_path, description, output_directory)

    # Call the GitHub upload script
    #os.system("python3 gitpush.py")   # called when connected to internet

