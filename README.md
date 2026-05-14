# tech-radar

5 个 Claude Code / Codex / Cursor / Gemini CLI 通用的 SKILL.md 雷达，覆盖计算机行业五个增长方向的英文一手源。补齐 [aihot](https://aihot.virxact.com/aihot-skill/) 这种中文 AI 摘要服务**够不到的非 AI 圈技术信号**。

| Skill | 方向 | 主数据源 |
|---|---|---|
| `tech-radar-ai-infra` | AI 编译 / 算子 / 推理优化 (TVM, MLIR, Triton, vLLM, FP8 量化) | arXiv `cs.PL`/`cs.LG`/`cs.PF` + Hacker News + lobste.rs/compilers + **OpenReview** (ICLR/NeurIPS/ICML) + **Bluesky** (策展 AI 研究者) + **官方 RSS** (OpenAI/HuggingFace/PyTorch/NVIDIA Dev) |
| `tech-radar-cloud-edge` | 云原生 / 分布式 / 边缘 (k8s, serverless, eBPF, MEC) | arXiv `cs.DC`/`cs.NI`/`cs.OS` + Hacker News + lobste.rs/distributed + **Bluesky** (策展 devops/k8s) + **LWN** |
| `tech-radar-hpc-hardware` | HPC / 加速器 / 互联 (H200, B200, NVLink, NCCL, CUTLASS) | arXiv `cs.AR`/`cs.PF` + Hacker News + lobste.rs/hardware + **Bluesky** (策展 perf/硬件) + **NVIDIA Dev Blog** + **Phoronix** |
| `tech-radar-dataops` | 数据栈 / 可视化 / 时序 (DuckDB, Iceberg, Polars, Observable) | arXiv `cs.DB` + Hacker News + lobste.rs/databases + **Bluesky** (策展 DB 官号) + **DuckDB feed** |
| `tech-radar-ai-industry` | AI 行业落地 (Robotaxi, humanoid, 工业 AI, 医疗 AI) | arXiv `cs.RO`/`eess.IV` + Hacker News + aihot 的 industry 类别 + **Bluesky** (策展 机器人/驾驶公司官号) + **OpenAI blog** (应用/案例条目) |

每个 SKILL.md 都是**纯路由 + curl 用法 + 输出格式约束**，没有运行时依赖（只用 `curl` + `python3` 标准库解析）。Skill 的"执行"是 Agent 读 SKILL.md 后按里面的规则发 HTTP 请求 → 解析 → 翻译摘要 → 排版输出。

### 数据源覆盖说明

- **arXiv / Hacker News / lobste.rs**：稳定免 key、机器友好。
- **OpenReview**：ICLR/NeurIPS/ICML 投稿池，v2 API 公开可读。venue id 格式为 `<host>.cc/<year>/<event>`，详见 ai-infra SKILL.md 第 4 节。
- **Bluesky**：`getAuthorFeed` 匿名可读（`searchPosts` 需 app-password 鉴权，本项目不走）。策略是**维护策展 handle 列表 → 逐一拉时间线 → 过滤**，每个 skill 列了候选 handle，未验证的请先 `resolveHandle` 探测。
- **官方 RSS**：每个 skill 配 1-4 个对口源，按 `pubDate` 倒序 + 时间窗截断到最近 7-14 天。
- **关于 X (Twitter)**：X 官方 API 付费 ($100+/mo)，Nitter 公共镜像 2024 年起被批量封杀。本项目**不直接抓 X**——AI 圈的 X 内容靠 [aihot](https://aihot.virxact.com/aihot-skill/) 已有覆盖；非 AI 的 X 内容用 Bluesky 替代（karpathy / 多数 AI 实验室都迁过去了）。

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
