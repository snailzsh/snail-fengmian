"""用法：python3 导出.py <cover.png> <输出.jpg>   转 JPG（质量 92），给 成片/封面_<比例>_<名字>.jpg 用"""
import sys, os
from PIL import Image
src, dst = sys.argv[1], sys.argv[2]; os.makedirs(os.path.dirname(os.path.abspath(dst)), exist_ok=True)
Image.open(src).convert('RGB').save(dst, quality=92); print(dst)
