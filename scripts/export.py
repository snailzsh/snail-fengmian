"""Usage: python3 export.py <cover.png> <dest.jpg>   转 JPG（质量 92）"""
import sys, os
from PIL import Image
if len(sys.argv) != 3: print(__doc__); sys.exit(1)
src, dst = sys.argv[1], sys.argv[2]
os.makedirs(os.path.dirname(os.path.abspath(dst)), exist_ok=True)
Image.open(src).convert('RGB').save(dst, quality=92); print(dst)
