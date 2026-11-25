"""Usage:
  python3 check.py <cover.png> <3:4|4:3|16:9>              量宽高比，出 25% 缩略图 cover_thumb.png
  python3 check.py --sheet <out.jpg> <img1> <label1> ...   拼对比图
"""
import sys, os, glob
from PIL import Image, ImageDraw, ImageFont

CJK_FONTS = [
    '/System/Library/Fonts/STHeiti Medium.ttc', '/System/Library/Fonts/PingFang.ttc',
    '/System/Library/Fonts/Hiragino Sans GB.ttc',
    '/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc', '/usr/share/fonts/noto-cjk/NotoSansCJK-Regular.ttc',
    '/usr/share/fonts/truetype/wqy/wqy-microhei.ttc', 'C:/Windows/Fonts/msyh.ttc',
] + glob.glob('/usr/share/fonts/**/*CJK*.tt[cf]', recursive=True)

def font(size):
    for p in CJK_FONTS:
        if os.path.exists(p):
            try: return ImageFont.truetype(p, size)
            except OSError: pass
    return ImageFont.load_default()

if len(sys.argv) < 3: print(__doc__); sys.exit(1)
if sys.argv[1] == '--sheet':
    out, rest = sys.argv[2], sys.argv[3:]
    items = list(zip(rest[::2], rest[1::2])); H, pad = 720, 24
    ims = [Image.open(p).convert('RGB') for p, _ in items]
    ims = [im.resize((int(im.width * H / im.height), H), Image.LANCZOS) for im in ims]
    S = Image.new('RGB', (pad + sum(im.width + pad for im in ims), H + pad * 2 + 60), (245, 243, 238))
    d = ImageDraw.Draw(S); f = font(34); x = pad
    for im, (_, lab) in zip(ims, items):
        S.paste(im, (x, pad)); d.text((x, H + pad + 12), lab, fill=(30, 30, 30), font=f); x += im.width + pad
    S.convert('RGB').save(out, quality=90); print(out, S.size); sys.exit()

p, ratio = sys.argv[1], sys.argv[2]
a, b = map(int, ratio.split(':')); im = Image.open(p); w, h = im.size
ok = abs(w * b - h * a) <= max(a, b) * 2
print(f'{p}: {w}x{h}  target {ratio}  {"OK 比例对" if ok else "WRONG 比例不对"}')
tp = os.path.splitext(p)[0] + '_thumb.png'; im.resize((w // 4, h // 4), Image.LANCZOS).save(tp)
print('thumbnail（目视检查标题和主体能否一眼认出）:', tp)
sys.exit(0 if ok else 3)
