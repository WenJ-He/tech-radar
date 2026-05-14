---
name: tech-radar-ai-industry
description: AI + 行业垂直落地方向的英文一手源雷达。触发关键词:自动驾驶、autonomous driving、L4、Robotaxi、Waymo、Cruise、Wayve、机器人、robotics、人形机器人、humanoid、具身智能、embodied AI、Figure、Tesla Optimus、Unitree、视觉语言动作模型、VLA、工业 AI、industrial AI、工业质检、defect detection、智能制造、smart manufacturing、predictive maintenance、金融 AI、fintech AI、金融风控、fraud detection、量化交易、algo trading、生物医药、biomedical AI、AI drug discovery、AI for science、医学影像、medical imaging、radiology AI、电子病历、临床决策、智慧城市、smart city、能源 AI、power grid AI、AI agent 应用、agentic application、垂直 AI、vertical AI、行业大模型、industry foundation model、多模态应用、multimodal application、API 聚合、microservice、模型服务化、model serving、低延迟推理(应用层)、跨系统集成。当用户问"自动驾驶最近的论文"、"人形机器人量产进度"、"AI 在金融风控的实战"、"医疗影像 AI 评测"等任何 AI + 行业落地方向时使用。**纯 AI 基础设施 / 模型 / 编译**走 [[tech-radar-ai-infra]],**纯 AI 产品消息**(Claude 更新等)走 aihot。本 skill 聚合 arXiv (cs.RO/eess.IV/q-bio.QM) + Hacker News + aihot 的 industry/ai-products 类别 三个免 key 源。
---

# Tech Radar — AI + 行业落地

聚焦**垂直行业的 AI 应用**:机器人、自动驾驶、工业、金融、医药、能源等。和其它 tech-radar 区分:

- **模型 / 编译 / 算子优化** → [[tech-radar-ai-infra]]
- **算力硬件 / 互联** → [[tech-radar-hpc-hardware]]
- **云原生部署** → [[tech-radar-cloud-edge]]
- **数据栈** → [[tech-radar-dataops]]
- **大模型公司发布(模型/产品)** → aihot 的 `ai-models` / `ai-products` 类别
- **本 skill** = **AI 怎么进入具体行业 + 行业里的 AI 案例 + 行业垂直论文**

## 路由

| 用户在说 | 走哪些源 |
|---|---|
| "自动驾驶 / Waymo / Wayve 进展" | HN + arXiv cs.RO |
| "人形机器人 / Figure / Optimus" | HN + arXiv cs.RO |
| "工业 AI / 质检 / 智能制造" | arXiv eess.IV + HN |
| "金融 AI / 风控 / 量化" | HN + arXiv q-fin.* |
| "医疗 AI / 影像 / 病历" | arXiv eess.IV + q-bio.QM + HN |
| "AI Agent 应用 / 垂直大模型" | aihot industry + ai-products + HN |
| **默认(宽问题)** "AI 落地行业有啥新东西" | 三源并行 |

## 数据源

### 1. arXiv API

类别速查:
| 类别 | 用途 |
|---|---|
| `cs.RO` | 机器人、规划、控制 |
| `eess.IV` | 图像/视频处理(医学影像、工业视觉) |
| `cs.CV` | 计算机视觉(VLA 等多模态) |
| `q-bio.QM` | 定量生物学(drug discovery) |
| `q-fin.ST` | 统计金融(量化、风控) |
| `cs.HC` | 人机交互(AI 助手应用) |

```bash
UA="Mozilla/5.0 tech-radar-skill/0.1.0"
curl -sLH "User-Agent: $UA" \
  "http://export.arxiv.org/api/query?search_query=cat:cs.RO+AND+all:%22humanoid%22&sortBy=submittedDate&sortOrder=descending&max_results=20"
```

**多次查询要串行 + ≥ 3 秒间隔**;XML 解析模板见 [[tech-radar-ai-infra]] SKILL.md。

### 2. Hacker News (Algolia)

```bash
since=$(date -d '7 days ago' +%s)
curl -sG "https://hn.algolia.com/api/v1/search_by_date" \
  --data-urlencode "query=robotics" \
  --data-urlencode "tags=story" \
  --data-urlencode "typoTolerance=false" \
  --data-urlencode "numericFilters=created_at_i>${since},points>=20" \
  --data-urlencode "restrictSearchableAttributes=title,url" \
  --data-urlencode "hitsPerPage=30"
```

关键词:
- 自动驾驶: `Waymo` / `Robotaxi` / `autonomous driving` / `L4`
- 机器人: `humanoid` / `Figure` / `Optimus` / `Unitree` / `embodied AI` / `VLA`
- 工业: `defect detection` / `industrial AI` / `predictive maintenance`
- 金融: `fraud detection` / `algo trading`(注意噪音多)
- 医疗: `medical imaging` / `drug discovery` / `radiology AI` / `clinical AI`
- 能源/城市: `smart grid` / `smart city`

**门槛 points>=20**:行业新闻在 HN 容易被刷,提高分数门槛过滤公关稿。

### 3. aihot.virxact.com (中文行业整理)

复用 aihot 的 `industry` + `ai-products` 类别 — 中文摘要质量高,适合补 HN 没覆盖的中文行业动态:

```bash
UA_AIHOT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 aihot-skill/0.2.0"
since=$(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%SZ)
curl -sH "User-Agent: $UA_AIHOT" \
  "https://aihot.virxact.com/api/public/items?mode=selected&category=industry&since=$since&take=50"
```

> 注意:这台 WSL 上 `aihot.virxact.com` 走本地代理 `127.0.0.1:7897` 会 TLS 报错,要 `env -u http_proxy -u https_proxy -u all_proxy ... curl ... --noproxy '*'` 直连。

## 工作流

1. 路由 → 选源
2. 并行拉(arXiv 多查询串行 + 3s,HN 与 aihot 并发)
3. URL 去重 + 时间倒序
4. arXiv 摘要中文翻译 + 1-2 句精炼
5. aihot 已有中文摘要直接用,**不要重译**

## 输出格式

```markdown
# AI 行业落地雷达 — 最近 7 天 · 共 N 条

## 论文(arXiv)
1. **<中文翻译标题>** — `arXiv:<id>` · cs.RO
   2 天前
   <1-2 句中文摘要>
   <abs link>

## 工程讨论(Hacker News)
2. **<原标题>** — HN · 425 分 · 230 评论
   昨天
   <link>

## 中文行业动态(AI HOT)
3. **<title>** — <source>
   3 天前
   <summary 50 字内>
   <url>
```

- 编号全局连续
- arXiv 摘要必翻 + 缩 1-2 句
- aihot 中文摘要直接用,不要重译

## 不要做

- arXiv 多次查询不能并发(3 秒间隔)
- HN 必带 `typoTolerance=false`
- aihot 调用必须带 aihot-skill 的 User-Agent,否则 nginx UA 黑名单挡 403
- 不展示基础设施细节
- **大模型本身的发布消息**(Claude 4.7 发布、GPT-5 发布)走 aihot 的 `ai-models` 类别 — 本 skill 关注的是"这些模型怎么进入特定行业"
- **算子/编译/推理优化论文**走 [[tech-radar-ai-infra]],本 skill 不重复
- 不要把投资/估值/财报新闻当核心 — 用户要的是技术与产品落地,不是融资八卦(融资走 aihot 的 `industry`)
- 不要把 LinkedIn 帖、营销稿、招聘启事当 signal — 这种 HN 上常见但低质量,points>=20 + 内容 check 双重过滤
