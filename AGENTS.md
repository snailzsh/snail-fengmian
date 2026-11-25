# AGENTS.md

This repository is an agent skill: **snail-fengmian** (video cover generator).

If your agent does not load skills automatically, do this whenever the user asks for a video cover / thumbnail / 封面:

1. Read `SKILL.md` in this directory and follow it step by step.
2. Templates live in `references/`, helper scripts in `scripts/`. Resolve every path relative to this directory.
3. For image generation, use your own image tool if you have one; otherwise run `scripts/generate.sh` (needs the Codex CLI).
4. Before delivering, run `scripts/check.py` and proofread every character yourself.

Reply to the user in their language. The prompt templates are in Chinese on purpose; keep them that way.
