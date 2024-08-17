#!/bin/bash

# Ensure both source and driving files are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source_image_path> <driving_video_path>"
    exit 1
fi

SOURCE=$1
DRIVING=$2
OUTPUT="output.mp4"

# Execute the curl command to call the API
curl -X POST -F "source=@${SOURCE}" -F "driving=@${DRIVING}" http://localhost:5000/process_image --output ${OUTPUT}

# Check if the output file was successfully created
if [ -f "$OUTPUT" ]; then
    echo "Process completed successfully. Output saved as ${OUTPUT}"
else
    echo "Failed to generate the output."
fi
