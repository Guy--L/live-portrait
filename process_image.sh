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
# once the instance is running on vast.ai, replace the IP:port address below with the instance's public IP address and port
curl -X POST -F "source=@${SOURCE}" -F "driving=@${DRIVING}" http://129.146.103.30:17218/process_image --output ${OUTPUT}

# Check if the output file was successfully created
if [ -f "$OUTPUT" ]; then
    echo "Process completed successfully. Output saved as ${OUTPUT}"
else
    echo "Failed to generate the output."
fi
