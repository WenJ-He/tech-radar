---
name: tech-radar-ai-infra
description: AI 基础设施 / 编译 / 算子优化方向的英文一手源雷达。触发关键词：AI 编译、AI compiler、深度学习编译器、TVM、MLIR、Triton、OpenAI Triton、XLA、JAX、CUTLASS、CuTe、Mojo、IREE、Glow、vLLM、TensorRT、TensorRT-LLM、SGLang、LMDeploy、TGI、Dynamo、torch.compile、算子优化、算子融合、kernel fusion、kernel writing、自动调度、auto-tuning、auto-scheduler、硬件感知编译、推理优化、inference optimization、推理加速、大模型量化、quantization、INT4、INT8、FP4、FP8、GPTQ、AWQ、SmoothQuant、LoRA、QLoRA、蒸馏、distillation、PTX、CUDA kernel、ROCm、Metal、ZLUDA、KV cache、PagedAttention、FlashAttention、speculative decoding、prefix caching、tensor core 优化、ICLR、NeurIPS、ICML、OpenReview、ICLR 投稿、NeurIPS workshop、Bluesky AI 圈、karpathy、HuggingFace 博客、PyTorch 博客、NVIDIA dev blog。当用户问"最近的算子融合论文"、"MLIR 社区在搞什么"、"vLLM 0.x 新特性"、"FP8 量化最佳实践"、"ICLR 2026 投稿热度"、"HuggingFace 最近博客"等任何 AI 基础设施 / 编译技术 / 推理优化方向时使用。**业界产品消息走 aihot；行业落地案例走 tech-radar-ai-industry**。本 skill 聚合 arXiv (cs.PL/cs.LG/cs.PF/cs.AR) + Hacker News + lobste.rs/compilers + OpenReview + Bluesky (AI 研究者) + 官方博客 RSS (OpenAI/HuggingFace/PyTorch/NVIDIA dev) 多个免 key 源。
---

# Tech Radar — AI 基础设施 / 编译 / 算子优化

聚合一手英文源,补齐 aihot 的中文摘要服务覆盖不到的研究/工程层。**聚焦深度学习编译器、算子优化、推理加速、量化蒸馏、硬件感知调度**；业界产品发布走 aihot；行业落地走 [[tech-radar-ai-industry]]。

## 路由

| 用户在说 | 走哪些源 |
|---|---|
| "最近 X 编译/算子/推理优化论文" | arXiv (默认) |
| "MLIR/TVM/Triton 社区在讨论啥" | lobste.rs/compilers + HN |
| "vLLM/TensorRT-LLM/SGLang 最近更新" | HN(by date + 关键词) |
| "FP8 量化"、"speculative decoding"、"kernel fusion" 综合 | arXiv + HN + lobste.rs 并行 |
| "ICLR / NeurIPS / ICML 投稿"、"大会上的 quantization 论文" | OpenReview |
| "karpathy / HF / PyTorch 团队最近聊啥" | Bluesky (策展 handles) |
| "OpenAI / HuggingFace / PyTorch / NVIDIA 最近博客" | 对应官方 RSS |
| **默认(宽问题)** "最近 AI infra 有啥新东西" | arXiv + HN + lobste.rs + 官方 RSS 并行 |

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

### 4. OpenReview (ICLR / NeurIPS / ICML 投稿)

- v2 API base: `https://api2.openreview.net`
- 公开 invitation 下的 notes 匿名可读 (accepted/public submissions)
- 主用法: 按 venue 的 Submission invitation 拉最新 notes
- **venue id 格式**: `<host>.cc/<year>/<event>` (如 `ICLR.cc/2026/Conference`、`NeurIPS.cc/2026/Conference`、`ICML.cc/2026/Conference`)
- Submission invitation 格式: `<venue_id>/-/Submission` (旧站) 或 `<venue_id>/-/Blind_Submission` / `<venue_id>/-/Submission` (v2)

```bash
# ICLR 2026 最新公开 submission (按提交时间倒序)
curl -sG "https://api2.openreview.net/notes" \
  --data-urlencode "invitation=ICLR.cc/2026/Conference/-/Submission" \
  --data-urlencode "sort=cdate:desc" \
  --data-urlencode "limit=20"

# 按关键词过滤 (content.keywords 字段)
curl -sG "https://api2.openreview.net/notes" \
  --data-urlencode "invitation=ICLR.cc/2026/Conference/-/Submission" \
  --data-urlencode "content.keywords=quantization" \
  --data-urlencode "limit=20"
```

返回结构 (简化):
```json
{"notes": [{
  "id": "<cuid>",
  "cdate": 1715123456789,
  "content": {
    "title": {"value": "..."},
    "abstract": {"value": "..."},
    "keywords": {"value": ["LLM", "quantization"]},
    "authors": {"value": ["..."]}
  },
  "forum": "<forum-id>",
  "number": 1234
}]}
```

论文 URL 模式: `https://openreview.net/forum?id=<forum-id>`。

**venue 列表速查**(2026):
- `ICLR.cc/2026/Conference`
- `NeurIPS.cc/2026/Conference`
- `ICML.cc/2026/Conference`
- `COLM.cc/2026/Conference`(Conference on Language Modeling)
- workshop 见 `https://openreview.net/group?id=<venue>` 网页

**fallback**:不确定 invitation 字符串时,先 `curl https://api2.openreview.net/venues?id=<venue_id>` 探测；或先用浏览器开 OpenReview 网站找会议页,把 URL 里的 venue id 抠出来。

### 5. Bluesky (AI 研究者迁移过来的)

- Public AppView: `https://public.api.bsky.app`
- **`getAuthorFeed` 匿名可用; `searchPosts` 需要 app-password 鉴权,本 skill 不走**
- 策略: **维护一份策展 handle 列表 → 逐一拉 timeline → 按时间窗 + 关键词过滤**

本 skill 推荐 handle (verified live ones marked ✓; 未验证的 trial-and-error):

| Handle | 内容 |
|---|---|
| `karpathy.bsky.social` ✓ | LLM/训练/推理观点 |
| `tri-dao.bsky.social` | FlashAttention 作者 (待验证) |
| `lmsys.bsky.social` | SGLang 团队 (待验证) |
| `simonw.bsky.social` | 工具/推理实战 (待验证) |
| `huggingface.bsky.social` | HF 官号 (待验证) |

```bash
# 拉单个 handle 最近 N 条
curl -sG "https://public.api.bsky.app/xrpc/app.bsky.feed.getAuthorFeed" \
  --data-urlencode "actor=karpathy.bsky.social" \
  --data-urlencode "limit=30"

# 探测 handle 是否存在
curl -sG "https://public.api.bsky.app/xrpc/com.atproto.identity.resolveHandle" \
  --data-urlencode "handle=karpathy.bsky.social"
# 200 + did → 存在; 400 InvalidRequest "Profile not found" → handle 错或没注册
```

返回 feed item 关键字段: `post.record.text` / `post.author.handle` / `post.indexedAt`(ISO) / `post.uri`(at:// URI) / `post.embed`(图片/外链)。

**用户友好 URL** 生成: `https://bsky.app/profile/<handle>/post/<rkey>` — rkey 是 `post.uri` 最后一段。

### 6. 官方博客 RSS

| 源 | RSS | 用途 |
|---|---|---|
| OpenAI Blog | `https://openai.com/blog/rss.xml` | 模型发布、Codex / Codex SDK / API 更新 |
| HuggingFace Blog | `https://huggingface.co/blog/feed.xml` | transformers、训练优化、量化、推理实战 |
| PyTorch Blog | `https://pytorch.org/blog/feed.xml` | torch.compile、性能、分布式训练 |
| NVIDIA Dev Blog | `https://developer.nvidia.com/blog/feed` | CUDA、Triton、TensorRT、cuDNN、Nsight |

```bash
# 通用 RSS 拉取(Atom 或 RSS 2.0 都行,Python 标准库直接解)
curl -sLH "User-Agent: tech-radar-skill/0.1.0" "https://openai.com/blog/rss.xml" -o /tmp/rss.xml

python3 - << 'PY'
import xml.etree.ElementTree as ET
root = ET.parse('/tmp/rss.xml').getroot()
# RSS 2.0
for item in root.iter('item'):
    title = (item.findtext('title') or '').strip()
    link = (item.findtext('link') or '').strip()
    pub = (item.findtext('pubDate') or '').strip()
    desc = (item.findtext('description') or '').strip()[:200]
    print(title, '|', pub, '|', link)
PY
```

注:`OpenAI` RSS items 上千条(全量历史),拉前要 `pubDate` 倒序 + 时间窗截断,**只取最近 7 天**。

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
- **Bluesky 不要走 `searchPosts`** — 公开 AppView 上该端点 403,要 app-password 鉴权;只用 `getAuthorFeed` + 策展 handles
- **OpenReview venue id 不要瞎猜** — 不确定时先用浏览器开会议页确认,或者 `curl /venues?id=<x>` 探测;乱传字符串会返回空 notes 列表(silent fail)
- **官方 RSS 必须按 pubDate 倒序 + 时间窗截断** — OpenAI/HF 的 feed 有几百到上千条全量历史,不截断会塞爆上下文
- 不要展示 arXiv API URL / Algolia objectID / `numericFilters=...` / `at://` URI / OpenReview forum-id 等基础设施细节 — 给用户的链接统一用 `https://openreview.net/forum?id=...` 和 `https://bsky.app/profile/<handle>/post/<rkey>` 这种人话 URL
- 不要把 arXiv abstract 或 OpenReview abstract 整段塞给用户 — 翻译 + 1-2 句精炼
- 不要做高频轮询 — arXiv 更新每天一次,新论文凌晨批量上线;HN/lobste.rs 5-10 分钟一次足够;Bluesky 个体账号低频发帖,1-2 小时拉一次够
- **业界产品发布消息(Claude Code 更新、vLLM 0.x release notes)优先走 aihot**,本 skill 拉到的 HN 帖子是社区讨论维度,不要重复
- **行业落地案例(自动驾驶/医疗/工业 AI 应用)走 [[tech-radar-ai-industry]]**,本 skill 不覆盖
- Bluesky handle 列表里的 ✓ 是已验证存在,**未验证项要先 `resolveHandle` 探测**再下手拉 timeline,否则会浪费请求
