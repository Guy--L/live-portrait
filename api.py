from flask import Flask, request, send_file, jsonify
import os
import subprocess
import uuid

app = Flask(__name__)

# Define a directory to temporarily store input and output files
UPLOAD_FOLDER = 'uploads'
OUTPUT_FOLDER = 'outputs'

os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

@app.route('/process_image', methods=['POST'])
def process_image():
    # Ensure 'source' and 'driving' files are provided
    if 'source' not in request.files or 'driving' not in request.files:
        return jsonify({"error": "Both 'source' and 'driving' files are required."}), 400

    # Save the uploaded files
    source_file = request.files['source']
    driving_file = request.files['driving']

    # Generate unique filenames
    source_filename = os.path.join(UPLOAD_FOLDER, f"{uuid.uuid4()}_{source_file.filename}")
    driving_filename = os.path.join(UPLOAD_FOLDER, f"{uuid.uuid4()}_{driving_file.filename}")
    output_filename = os.path.join(OUTPUT_FOLDER, f"{uuid.uuid4()}_output.mp4")

    source_file.save(source_filename)
    driving_file.save(driving_filename)

    # Run the inference script
    try:
        subprocess.run(
            ['python', 'inference.py', '--source', source_filename, '--driving', driving_filename, '--output_dir', OUTPUT_FOLDER],
            check=True
        )
    except subprocess.CalledProcessError as e:
        return jsonify({"error": str(e)}), 500

    # Check if the output file was created
    if not os.path.exists(output_filename):
        return jsonify({"error": "Failed to generate the output file."}), 500

    # Return the generated MP4 file
    return send_file(output_filename, as_attachment=True)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
