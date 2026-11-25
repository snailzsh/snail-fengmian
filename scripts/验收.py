"""用法：
  python3 验收.py <cover.png> <比例 3:4|4:3|16:9>      实测比例 + 出 25% 缩略图（cover_thumb.png）
  python3 验收.py --sheet <输出.jpg> <图1> <标签1> <图2> <标签2> …   拼对比图
"""
import sys
from PIL import Image, ImageDraw, ImageFont
FONT = '/System/Library/Fonts/STHeiti Medium.ttc'
if sys.argv[1] == '--sheet':
    out, rest = sys.argv[2], sys.argv[3:]
    items = list(zip(rest[::2], rest[1::2])); H = 720; pad = 24
    ims = [Image.open(p).convert('RGB') for p, _ in items]
    ims = [im.resize((int(im.width * H / im.height), H), Image.LANCZOS) for im in ims]
    W = pad + sum(im.width + pad for im in ims)
    S = Image.new('RGB', (W, H + pad * 2 + 60), (245, 243, 238)); d = ImageDraw.Draw(S); f = ImageFont.truetype(FONT, 34); x = pad
    for im, (_, lab) in zip(ims, items):
        S.paste(im, (x, pad)); d.text((x, H + pad + 12), lab, fill=(30, 30, 30), font=f); x += im.width + pad
    S.save(out, quality=90); print(out, S.size); sys.exit()
p, ratio = sys.argv[1], sys.argv[2]
a, b = map(int, ratio.split(':')); im = Image.open(p); w, h = im.size
ok = abs(w * b - h * a) <= max(a, b) * 2
print(f'{p}: {w}x{h}  目标 {ratio}  {"比例对" if ok else "比例不对！"}')
t = im.resize((w // 4, h // 4), Image.LANCZOS); tp = p.rsplit('.', 1)[0] + '_thumb.png'; t.save(tp)
print('缩略图（目视检查标题和主体能不能一眼认出）:', tp)
