# snail-fengmian · 片子封面 skill

给 Claude Code 用的视频封面 skill：**封面从片子里长出来**。标题就是片子的钩子，主体用片子里真出现过的画面或物件，用 Codex 内置生图一次出完整封面（字和画面一体），出图后逐字核对、看缩略图，3:4 / 4:3 / 16:9 三个比例各自构图。

## 三种模式

| 模式 | 适合 | 来源 |
|---|---|---|
| 出镜·实物 | 本人讲解、复盘、口播 | simon 调查封面 + 人物反应 |
| 无人·拼贴 | 科普、新闻解读，要冲击力 | gbro 风格六 海报拼贴，素材图代替人物层 |
| 无人·实物 | 科普、讲史，有能演出来的比喻 | simon 调查封面，不放人物 |

总原则（每份提示词都带）：

> 请根据每次上传人物的姿态、服装颜色、视线方向和背景空间，自适应调整标题位置、装饰元素与构图关系。保留参考图的设计逻辑，但不要复制完全相同的版式，每次生成都要有合理变化。

| 无人·实物 16:9 | 无人·拼贴 16:9 |
|---|---|
| ![](examples/无人实物_16比9.jpg) | ![](examples/无人拼贴_16比9.jpg) |

## 安装

```bash
git clone https://github.com/snailzsh/snail-fengmian ~/.claude/skills/snail-fengmian
```

- 出镜模式要放一张自己的头像：`assets/头像.png`（已加进 .gitignore）。
- 依赖：[Codex CLI](https://github.com/openai/codex)（用它的内置生图）、ffmpeg、Python 3 + Pillow。字体路径按 macOS 写的。

## 目录

- `SKILL.md`：流程（问模式 → 从成片抽帧取材 → 标题规则 → 套模板 → 出图 → 验收 → 导出）
- `references/`：三种模式的模板和自适应段
- `scripts/`：`抽帧.sh`、`出图.sh`、`验收.py`（量比例、出缩略图、拼对比图）、`导出.py`
- `examples/`：样张

## 来源和许可

2026-11 横评四个封面 skill 后融合而成：
- [trustfuture/simon-skills](https://github.com/trustfuture/simon-skills)：MIT，Copyright (c) 2026 trustfuture
- [pyang5166/gbro-cover-design](https://github.com/pyang5166/gbro-cover-design)：MIT，Copyright (c) 2026 狗哥笔记
- 参考：[oil-oil/oil-cover](https://github.com/oil-oil/oil-cover)、[Vivixiao980/xhs-cover-skill](https://github.com/Vivixiao980/xhs-cover-skill)

本仓库用 MIT 许可，见 LICENSE。样张里的 1945 年 Trinity 核试验照片属于美国政府公有领域。
