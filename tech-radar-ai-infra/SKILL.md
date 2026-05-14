---
name: tech-radar-ai-infra
description: AI 基础设施 / 编译 / 算子优化方向的英文一手源雷达。触发关键词：AI 编译、AI compiler、深度学习编译器、TVM、MLIR、Triton、OpenAI Triton、XLA、JAX、CUTLASS、CuTe、Mojo、IREE、Glow、vLLM、TensorRT、TensorRT-LLM、SGLang、LMDeploy、TGI、Dynamo、torch.compile、算子优化、算子融合、kernel fusion、kernel writing、自动调度、auto-tuning、auto-scheduler、硬件感知编译、推理优化、inference optimization、推理加速、大模型量化、quantization、INT4、INT8、FP4、FP8、GPTQ、AWQ、SmoothQuant、LoRA、QLoRA、蒸馏、distillation、PTX、CUDA kernel、ROCm、Metal、ZLUDA、KV cache、PagedAttention、FlashAttention、speculative decoding、prefix caching、tensor core 优化。当用户问"最近的算子融合论文"、"MLIR 社区在搞什么"、"vLLM 0.x 新特性"、"FP8 量化最佳实践"等任何 AI 基础设施 / 编译技术 / 推理优化方向时使用。**业界产品消息走 aihot；行业落地案例走 tech-radar-ai-industry**。本 skill 聚合 arXiv (cs.PL/cs.LG/cs.PF/cs.AR) + Hacker News + lobste.rs/compilers 三个免 key 源。
---

# Tech Radar — AI 基础设施 / 编译 / 算子优化

聚合一手英文源,补齐 aihot 的中文摘要服务覆盖不到的研究/工程层。**聚焦深度学习编译器、算子优化、推理加速、量化蒸馏、硬件感知调度**；业界产品发布走 aihot；行业落地走 [[tech-radar-ai-industry]]。

## 路由

| 用户在说 | 走哪些源 |
|---|---|
| "最近 X 编译/算子/推理优化论文" | arXiv (默认) |
| "MLIR/TVM/Triton 社区在讨论啥" | lobste.rs/compilers + HN |
| "vLLM/TensorRT-LLM/SGLang 最近更新" | HN(by date + 关键词) |
| "FP8 量化"、"speculative decoding"、"kernel fusion" 综合 | 三源并行 |
| **默认(宽问题)** "最近 AI infra 有啥新东西" | 三源并行 |

## 数据源

### 1. arXiv API

- Base: `http://export.arxiv.org/api/query`(**必带 `-L`**,会 301 重定向)
- **官方礼仪:连续请求间隔 ≥ 3 秒**,违反会被封 UA
- 返回 Atom XML

类别速查(本 skill 范围):
| 类别 | 用途 |
|---|---|
| `cs.PL` | 编程语言、编译器、IR(含 MLIR/LLVM/TVM 工作) |
| `cs.LG` | 机器学习(LLM 训练/推理优化) |
| `cs.PF` | 性能分析、profiling |
| `cs.AR` | 硬件架构(GPU/加速器侧研究) |
| `cs.DC` | 分布式/并行计算(大模型分布式训练) |

```bash
UA="Mozilla/5.0 tech-radar-skill/0.1.0"

# 单类别最新 20 条
curl -sLH "User-Agent: $UA" \
  "http://export.arxiv.org/api/query?search_query=cat:cs.PL&sortBy=submittedDate&sortOrder=descending&max_results=20"

# 类别 OR + 关键词全文搜
curl -sLH "User-Agent: $UA" \
  "http://export.arxiv.org/api/query?search_query=%28cat:cs.PL+OR+cat:cs.LG%29+AND+all:%22kernel+fusion%22&sortBy=submittedDate&sortOrder=descending&max_results=20"
```

Atom XML 解析(Python 标准库,免装包):

```bash
python3 - << 'PY'
import xml.etree.ElementTree as ET, urllib.request, urllib.parse, time
q = urllib.parse.urlencode({
    "search_query": "cat:cs.PL",
    "sortBy": "submittedDate", "sortOrder": "descending",
    "max_results": 20,
})
url = f"http://export.arxiv.org/api/query?{q}"
req = urllib.request.Request(url, headers={"User-Agent": "tech-radar-skill/0.1.0"})
data = urllib.request.urlopen(req, timeout=20).read()
ns = {"a": "http://www.w3.org/2005/Atom"}
root = ET.fromstring(data)
for e in root.findall("a:entry", ns):
    title = (e.findtext("a:title", "", ns) or "").strip().replace("\n", " ")
    updated = e.findtext("a:updated", "", ns)
    abs_url = next((l.get("href") for l in e.findall("a:link", ns) if l.get("rel") == "alternate"), "")
    summary = (e.findtext("a:summary", "", ns) or "").strip().split("\n\n")[0][:300]
    print(title, "|", updated, "|", abs_url)
PY
```

### 2. Hacker News (Algolia)

- Base: `https://hn.algolia.com/api/v1/search_by_date`
- **必带 `typoTolerance=false`**,否则 "TVM" 会匹配 "tim"
- `numericFilters=points>=10` 过滤低分噪音
- `numericFilters=created_at_i>EPOCH` 限时间窗(epoch 秒)

```bash
since=$(date -d '7 days ago' +%s)
curl -sG "https://hn.algolia.com/api/v1/search_by_date" \
  --data-urlencode "query=vLLM" \
  --data-urlencode "tags=story" \
  --data-urlencode "typoTolerance=false" \
  --data-urlencode "numericFilters=created_at_i>${since},points>=10" \
  --data-urlencode "restrictSearchableAttributes=title,url" \
  --data-urlencode "hitsPerPage=30"
```

关键词组合建议:
- 编译: `TVM` / `MLIR` / `Triton` / `XLA` / `CUTLASS` / `IREE` / `Mojo`
- 推理框架: `vLLM` / `TensorRT-LLM` / `SGLang` / `LMDeploy`
- 量化/优化: `FP8` / `FP4` / `GPTQ` / `AWQ` / `FlashAttention` / `PagedAttention`
- 硬件: `ROCm` / `CUDA` / `Hopper` / `Blackwell`

返回字段:`title` / `url` / `points` / `num_comments` / `created_at` / `created_at_i`。

### 3. lobste.rs

- `https://lobste.rs/t/<tag>.json` 拿该 tag 最近 25 条
- 本 skill 用 tags: `compilers` / `performance` / `ml` / `gpus`

```bash
UA="Mozilla/5.0 tech-radar-skill/0.1.0"
curl -sLH "User-Agent: $UA" "https://lobste.rs/t/compilers.json"
curl -sLH "User-Agent: $UA" "https://lobste.rs/t/performance.json"
```

返回字段:`title` / `url` / `created_at`(ISO+TZ) / `score` / `comment_count` / `tags` / `description`。

## 工作流

1. 识别用户意图 → 路由到 1-3 个源(看上面"路由"表)
2. 并行拉源;**arXiv 多次查询要串行 + 3 秒间隔**,HN 和 lobste.rs 可与 arXiv 并发
3. URL 去重:strip `?utm_*` / trailing `/` / fragment
4. 按 `created_at` / `updated` 倒序
5. arXiv title/abstract 翻成中文(Claude 自己翻),每条 abstract 缩到 1-2 句

## 输出格式

```markdown
# AI 基础设施雷达 — 最近 7 天 · 共 N 条

## 论文(arXiv)
1. **<中文翻译标题>** — `arXiv:<id>` · cs.PL
   3 天前
   <1-2 句中文摘要>
   <abs link>

## 工程讨论(Hacker News)
2. **<原标题>** — HN · 142 分 · 67 评论
   昨天
   <link>

## 社区精选(lobste.rs)
3. **<标题>** — lobste.rs/compilers · 28 分
   2 天前
   <link>
```

- 编号**全局连续**,不在每个 ## 内重置(用户能一眼数总条数)
- arXiv abstract 必须翻译成中文 + 缩成 1-2 句
- 时间转人话:"3 天前" / "昨天" / "5/10",不要 ISO 字符串
- 默认每源 top 5-10 条;用户说"全部/完整"才放开

## 不要做

- **arXiv 多次查询不能并发** — 官方要求间隔 3 秒,违反会封 UA
- **HN 必带 `typoTolerance=false`** — 否则 TVM 匹配到 "tim"、FP8 匹配到 "fps" 这类垃圾
- 不要展示 arXiv API URL / Algolia objectID / `numericFilters=...` 等基础设施细节
- 不要把 arXiv abstract 整段塞给用户 — 翻译 + 1-2 句精炼
- 不要做高频轮询 — arXiv 更新每天一次,新论文凌晨批量上线;HN/lobste.rs 5-10 分钟一次足够
- **业界产品发布消息(Claude Code 更新、vLLM 0.x release notes)优先走 aihot**,本 skill 拉到的 HN 帖子是社区讨论维度,不要重复
- **行业落地案例(自动驾驶/医疗/工业 AI 应用)走 [[tech-radar-ai-industry]]**,本 skill 不覆盖
