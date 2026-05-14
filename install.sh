#!/usr/bin/env bash
# tech-radar — 一键安装 5 个 SKILL.md 到 Agent 的 skills 目录
#
# 默认装到 Claude Code 的 ~/.claude/skills/
#   curl -fsSL https://raw.githubusercontent.com/WenJ-He/tech-radar/main/install.sh | bash
#
# 其它 Agent 平台:
#   SKILL_DIR=$HOME/.codex/skills    bash <(curl -fsSL https://raw.githubusercontent.com/WenJ-He/tech-radar/main/install.sh)
#   SKILL_DIR=$HOME/.gemini/skills   bash <(curl -fsSL https://raw.githubusercontent.com/WenJ-He/tech-radar/main/install.sh)

set -e

DEFAULT_DIR="$HOME/.claude/skills"
SKILL_DIR="${SKILL_DIR:-$DEFAULT_DIR}"
REPO_BASE="https://raw.githubusercontent.com/WenJ-He/tech-radar/main"

SKILLS=(
  tech-radar-ai-infra
  tech-radar-cloud-edge
  tech-radar-hpc-hardware
  tech-radar-dataops
  tech-radar-ai-industry
)

echo ""
echo "Installing tech-radar (5 skills)"
echo "  → $SKILL_DIR"
echo ""

for s in "${SKILLS[@]}"; do
  echo "  [$s]"
  mkdir -p "$SKILL_DIR/$s"
  curl -fsSL "$REPO_BASE/$s/SKILL.md" -o "$SKILL_DIR/$s/SKILL.md"
done

echo ""
echo "✓ Done."
echo ""
echo "Next: restart your Agent or start a new conversation, then try:"
echo "  - 最近一周的 MLIR / Triton 论文"
echo "  - DuckDB / Polars 最近的进展"
echo "  - H200 FP8 实测、NVLink 拓扑"
echo "  - 人形机器人最近的论文和量产消息"
echo ""
