# tech-radar

5 个 Claude Code / Codex / Cursor / Gemini CLI 通用的 SKILL.md 雷达，覆盖计算机行业五个增长方向的英文一手源。补齐 [aihot](https://aihot.virxact.com/aihot-skill/) 这种中文 AI 摘要服务**够不到的非 AI 圈技术信号**。

| Skill | 方向 | 主数据源 |
|---|---|---|
| `tech-radar-ai-infra` | AI 编译 / 算子 / 推理优化 (TVM, MLIR, Triton, vLLM, FP8 量化) | arXiv `cs.PL`/`cs.LG`/`cs.PF` + Hacker News + lobste.rs/compilers |
| `tech-radar-cloud-edge` | 云原生 / 分布式 / 边缘 (k8s, serverless, eBPF, MEC) | arXiv `cs.DC`/`cs.NI`/`cs.OS` + Hacker News + lobste.rs/distributed |
| `tech-radar-hpc-hardware` | HPC / 加速器 / 互联 (H200, B200, NVLink, NCCL, CUTLASS) | arXiv `cs.AR`/`cs.PF` + Hacker News + lobste.rs/hardware |
| `tech-radar-dataops` | 数据栈 / 可视化 / 时序 (DuckDB, Iceberg, Polars, Observable) | arXiv `cs.DB` + Hacker News + lobste.rs/databases |
| `tech-radar-ai-industry` | AI 行业落地 (Robotaxi, humanoid, 工业 AI, 医疗 AI) | arXiv `cs.RO`/`eess.IV` + Hacker News + aihot 的 industry 类别 |

每个 SKILL.md 都是**纯路由 + curl 用法 + 输出格式约束**，没有运行时依赖（只用 `curl` + `python3` 标准库解析）。Skill 的"执行"是 Agent 读 SKILL.md 后按里面的规则发 HTTP 请求 → 解析 → 翻译摘要 → 排版输出。

## 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/WenJ-He/tech-radar/main/install.sh | bash
```

装到 Claude Code 的 `~/.claude/skills/` 下，5 个 skill 各占一个子目录。

其它 Agent 平台：

```bash
SKILL_DIR=$HOME/.codex/skills    bash <(curl -fsSL https://raw.githubusercontent.com/WenJ-He/tech-radar/main/install.sh)
SKILL_DIR=$HOME/.gemini/skills   bash <(curl -fsSL https://raw.githubusercontent.com/WenJ-He/tech-radar/main/install.sh)
```

## 手动安装

```bash
git clone --depth 1 https://github.com/WenJ-He/tech-radar.git
cp -r tech-radar/tech-radar-* ~/.claude/skills/
```

## 装完试一下

重启 Agent（或开新会话），用自然中文问就行：

- "最近一周的 MLIR 论文" → `tech-radar-ai-infra`
- "k8s 1.32 新特性讨论" → `tech-radar-cloud-edge`
- "H200 FP8 实测性能" → `tech-radar-hpc-hardware`
- "DuckDB 最新进展" → `tech-radar-dataops`
- "人形机器人最近的论文和量产消息" → `tech-radar-ai-industry`

## 设计要点

- **arXiv 多查询必须串行 + 间隔 ≥ 3 秒**（官方礼仪，违反会被封 UA）
- **Hacker News Algolia 必带 `typoTolerance=false`**（否则 "TVM" 会匹配 "tim"、"FP8" 匹配 "fps"）
- 每个 skill 都标了**边界**："这块走另一个 skill"——避免重复触发
- 输出格式跟 aihot 对齐：编号全局连续、时间转人话、arXiv 摘要翻译成中文 + 缩 1-2 句

## License

MIT
