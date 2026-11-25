---
name: snail-fengmian
description: Video cover generator — "the cover grows out of the film". Builds a complete AI cover (text and scene in one image) from the video's own hook and key frames, in three modes (on-camera + prop, faceless collage, faceless prop), at 3:4 / 4:3 / 16:9, then checks every character and the thumbnail. Works with any agent that can run shell commands; image generation uses the agent's own image tool or the bundled Codex CLI script. 视频封面 skill：从片子的钩子和关键帧出完整封面（出镜·实物 / 无人·拼贴 / 无人·实物），三比例各自构图，逐字验收。Use when the user asks for a video cover / thumbnail / 封面 / 视频封面 / 出镜封面 / 无人封面 / 按视频内容做封面 / snail-fengmian.
license: MIT
---

# snail-fengmian：视频封面

一句话：**封面从片子里长出来**。标题就是片子的钩子，主体是片子里真出现过的画面或物件；人物如果出镜，是在对这个物件做反应。

> 本文件不依赖特定 agent。凡是能跑 shell 的 agent（Claude Code、Codex、Gemini CLI、Cursor、OpenClaw 等）都能照着走。下文的路径都相对于本 skill 目录（下称 `$SKILL`）。

## 总原则：自适应构图（每份提示词都要带）
> 请根据每次上传人物的姿态、服装颜色、视线方向和背景空间，自适应调整标题位置、装饰元素与构图关系。保留参考图的设计逻辑，但不要复制完全相同的版式，每次生成都要有合理变化。

无人模式把「人物的姿态、服装颜色、视线方向」换成「素材画面的主体位置、主色调、运动方向」。两段原文在 `references/adaptive.md`。模板末尾的 `{ADAPTIVE_ONCAM}` / `{ADAPTIVE_FACELESS}` 就是这两段，不能省。

## 0. 先定模式和比例
用户没说时，先给建议再问（如果所在项目有自己的封面规则，按项目规则走）：

| 模式 | 什么时候用 | 模板 |
|---|---|---|
| **出镜·实物** | 作者本人在讲：讲解、复盘、口播 | `references/mode-oncam-object.md` |
| **无人·拼贴** | 科普、新闻解读，要冲击力，短视频信息流 | `references/mode-faceless-collage.md` |
| **无人·实物** | 科普、讲史，有一个能演出来的比喻 | `references/mode-faceless-object.md` |

比例默认三张：3:4（竖版信息流、小红书）、4:3（公众号、B 站）、16:9（横屏播放器）。**每个比例单独写提示词、重新排版，不拿一张去裁。**

| 比例 | 参考尺寸 | 横版要点 |
|---|---|---|
| 3:4 | 1086×1448 | 标题占上三分之一，主体在中下部 |
| 4:3 | 1448×1086 | 标题放左侧约 45%，主体放右侧 |
| 16:9 | 1672×941 | 同 4:3，字可以更大 |

## 1. 从片子里取材（必须）
1. 读片子的台本、事实核查、发布文案，找到**一句钩子**（就是封面标题）和**一个比喻或物件**。
2. 抽帧看全片：`bash $SKILL/scripts/extract_frames.sh <video.mp4> <out_dir> [间隔秒=6]` 生成 `contact.jpg` 网格；挑 2–4 张关键帧，用 `bash $SKILL/scripts/extract_frames.sh <video.mp4> <out_dir> -t 30 36` 取全分辨率单帧。
3. 素材分三类，提示词里写清每张参考图是什么：
   - **主体**：最有冲击的真实画面，占画面 ≥35%；夹在物件上的照片，主体至少占整幅画面 15%，否则缩略图上看不出来。
   - **证据**：截图、数据、曲线，做成卡片，不承担可读性。
   - **纹理**：代码、地图、档案，模糊铺底。
4. 真实公开素材照用，注意授权；概念道具（作业本、账本）可以 AI 造，但**不伪造真实文件、单据、证照、读数**。

## 2. 标题规则
- 两行，每行 ≤5 个汉字（英文 ≤3 个词）。主标题只出现一次。
- 副标题或标签 ≤10 字，放在黄色实体标签里。
- 口径不超出事实：没证实的事加问号，或用「宣布 / 声称」。

## 3. 写提示词
- 套用模式模板，存成 `<cover_dir>/<mode>_<ratio>/prompt.txt`（例：`faceless-object_3x4/prompt.txt`）。
- 第一行固定：`只生成一次图片，保存为当前目录下的 cover.png，然后回报原始文件路径和像素尺寸。不要生成多张。`
- 出镜模式：参考图 1 是作者头像，第二行写 `必须是附带参考照片里的同一个人，不要换脸`。头像查找顺序：用户本次给的图 → 环境变量 `FENGMIAN_AVATAR` → `$SKILL/assets/avatar.png`。都没有就问用户要。表情默认**轻微惊讶**（眉毛轻扬、嘴微张、眼睛不瞪大），用户另有偏好就按用户的。
- **硬规则**（四个原 skill 横评时踩过的坑）：
  - 人物、主体、卡片**不能遮挡标题笔画**。提示词写明：「每个字都必须完整可认，遮挡只允许压到字形外缘」。
  - 右上角约 22%×12% 留空，给平台角标或字标。
  - 英文长文卡只当质感；要能读的信息，放大成 ≤8 字的中文或数字。
  - 装饰元素 ≤5 个，避免营销号味。

## 4. 出图（两条路，选一条）
- **A. agent 自带生图工具**（如 Codex 的 image_gen、Gemini 图像模型、ChatGPT 图像等）：把 prompt.txt 原文和参考图交给它，结果存成任务目录里的 `cover.png`。
- **B. 用脚本**：`bash $SKILL/scripts/generate.sh <task_dir> [参考图...]`，后台调用 [Codex CLI](https://github.com/openai/codex) 的内置生图（要先 `codex login`）。
  - 可选环境变量：`FENGMIAN_CODEX_MODEL` 指定模型，`FENGMIAN_CODEX_EFFORT` 指定推理强度（默认 low）。
  - 一张约 1–2 分钟。多张按顺序跑，不要并发（会撞额度）。
  - 重跑时，旧图会自动改名为 `cover-vN.png` 留着。

## 5. 验收（全部做完才交付）
`python3 $SKILL/scripts/check.py <cover.png> <3:4|4:3|16:9>`：量实际宽高比，生成 25% 缩略图 `cover_thumb.png`。然后：
- **逐字目视核对**标题、标签和所有文字（OCR 只能辅助）。有错字，或字被遮得认不出来，就改提示词里的遮挡规则重出。
- **看缩略图**：标题和主体一眼能认出来。
- 事实口径再对一遍。
- 多张时拼对比图：`python3 $SKILL/scripts/check.py --sheet <out.jpg> <img1> <label1> <img2> <label2> …`

## 6. 交付
- 转 JPG：`python3 $SKILL/scripts/export.py <cover.png> <dest.jpg>`。建议命名 `封面_<比例>_<名字>.jpg`。
- 用当前 agent 能用的方式把文件交给用户（文件卡片、路径、附件都行）。
- 不替用户发布；封面和发布文案要是同一版本。

## 依赖
ffmpeg、Python 3 + Pillow；走 B 路要装 Codex CLI。脚本在 macOS 和 Linux 上都能跑；Windows 用 WSL 或 Git Bash。

## 来源
融合自 [trustfuture/simon-skills](https://github.com/trustfuture/simon-skills)（调查封面规范、cover-qa）和 [pyang5166/gbro-cover-design](https://github.com/pyang5166/gbro-cover-design)（10 种构图风格，想换风格时翻），两者都是 MIT 许可。横评时还参考了 [oil-oil/oil-cover](https://github.com/oil-oil/oil-cover)、[Vivixiao980/xhs-cover-skill](https://github.com/Vivixiao980/xhs-cover-skill)。样张在 `examples/`。
