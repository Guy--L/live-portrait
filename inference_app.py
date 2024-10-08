from flask import Flask, request, jsonify
import os
import os.path as osp
import subprocess
from src.config.argument_config import ArgumentConfig
from src.config.inference_config import InferenceConfig
from src.config.crop_config import CropConfig
from src.live_portrait_pipeline import LivePortraitPipeline

app = Flask(__name__)

def partial_fields(target_class, kwargs):
    return target_class(**{k: v for k, v in kwargs.items() if hasattr(target_class, k)})

def fast_check_ffmpeg():
    try:
        subprocess.run(["ffmpeg", "-version"], capture_output=True, check=True)
        return True
    except:
        return False

def fast_check_args(args: ArgumentConfig):
    if not osp.exists(args.source):
        raise FileNotFoundError(f"source info not found: {args.source}")
    if not osp.exists(args.driving):
        raise FileNotFoundError(f"driving info not found: {args.driving}")

def process_image(source_path, driving_path, output_path):

    args = ArgumentConfig(
        source=source_path,
        driving=driving_path,
        output=output_path
    )

    ffmpeg_dir = os.path.join(os.getcwd(), "ffmpeg")
    if osp.exists(ffmpeg_dir):
        os.environ["PATH"] += (os.pathsep + ffmpeg_dir)

    if not fast_check_ffmpeg():
        raise ImportError(
            "FFmpeg is not installed. Please install FFmpeg (including ffmpeg and ffprobe) before running this script. https://ffmpeg.org/download.html"
        )

    fast_check_args(args)

    inference_cfg = partial_fields(InferenceConfig, args.__dict__)
    crop_cfg = partial_fields(CropConfig, args.__dict__)

    live_portrait_pipeline = LivePortraitPipeline(
        inference_cfg=inference_cfg,
        crop_cfg=crop_cfg
    )

    live_portrait_pipeline.execute(args)

@app.route('/process_image', methods=['POST'])
def api_process_image():
    if 'source' not in request.files or 'driving' not in request.files:
        return jsonify({'error': 'Missing source or driving file'}), 400

    source_file = request.files['source']
    driving_file = request.files['driving']

    source_path = os.path.join('uploads', source_file.filename)
    driving_path = os.path.join('uploads', driving_file.filename)
    output_path = os.path.join('output', 'result.mp4')

    os.makedirs('uploads', exist_ok=True)
    os.makedirs('output', exist_ok=True)

    source_file.save(source_path)
    driving_file.save(driving_path)

    try:
        process_image(source_path, driving_path, output_path)
        return jsonify({'result': output_path}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='209.20.157.223', port=32768)
