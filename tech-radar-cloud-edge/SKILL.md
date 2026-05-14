---
name: tech-radar-cloud-edge
description: 云计算与边缘计算方向的英文一手源雷达。触发关键词:云计算、cloud computing、分布式系统、distributed systems、Kubernetes、k8s、container orchestration、serverless、无服务计算、FaaS、Lambda、Cloud Run、Fargate、主权云、sovereign cloud、企业云、区域云、私有云、混合云、hybrid cloud、多云、multi-cloud、弹性伸缩、autoscaling、resource scheduling、资源调度、cluster scheduler、边缘计算、edge computing、边缘 AI、edge AI、边缘推理、edge inference、低延迟推理、低延迟、low-latency、5G MEC、IoT 平台、Cloudflare Workers、Fastly Compute、Wasm runtime、WebAssembly、service mesh、Istio、Linkerd、Envoy、observability、tracing、OpenTelemetry、eBPF、CNI、CSI、Karpenter、KEDA、Crossplane。当用户问"k8s 最近新特性"、"serverless 行业有什么新东西"、"边缘 AI 推理新方案"、"分布式系统论文综述"等任何云原生 / 分布式 / 边缘方向时使用。聚合 arXiv (cs.DC/cs.NI/cs.OS) + Hacker News + lobste.rs/distributed,devops 三个免 key 源。
---

# Tech Radar — 云计算 & 边缘计算

聚焦**云原生基础设施、分布式系统、边缘推理**。AI 加速器侧的硬件研究走 [[tech-radar-hpc-hardware]];模型推理本身的编译优化走 [[tech-radar-ai-infra]];本 skill 是它们的**部署/运行时/调度**这一层。

## 路由

| 用户在说 | 走哪些源 |
|---|---|
| "最近 k8s/serverless/Istio 进展" | HN + lobste.rs/distributed |
| "分布式系统/共识算法论文" | arXiv cs.DC |
| "边缘推理 / 5G MEC" | arXiv cs.NI + HN |
| "eBPF / observability / Envoy" | lobste.rs/devops + HN |
| **默认(宽问题)** "云原生最近啥新东西" | 三源并行 |

## 数据源

### 1. arXiv API

类别速查:
| 类别 | 用途 |
|---|---|
| `cs.DC` | 分布式 / 并行 / 云计算 |
| `cs.NI` | 网络 / 边缘网络 / 5G |
| `cs.OS` | 操作系统 / 容器运行时 / 内核 |

- Base: `http://export.arxiv.org/api/query` (带 `-L`)
- **连续请求间隔 ≥ 3 秒**
- Atom XML,Python 标准库 ElementTree 解析(模板见 [[tech-radar-ai-infra]] SKILL.md)

```bash
UA="Mozilla/5.0 tech-radar-skill/0.1.0"
curl -sLH "User-Agent: $UA" \
  "http://export.arxiv.org/api/query?search_query=%28cat:cs.DC+OR+cat:cs.NI%29+AND+all:%22edge+inference%22&sortBy=submittedDate&sortOrder=descending&max_results=20"
```

### 2. Hacker News (Algolia)

- Base: `https://hn.algolia.com/api/v1/search_by_date`
- **必带 `typoTolerance=false`**
- `numericFilters=points>=10` 过噪音

```bash
since=$(date -d '7 days ago' +%s)
curl -sG "https://hn.algolia.com/api/v1/search_by_date" \
  --data-urlencode "query=Kubernetes" \
  --data-urlencode "tags=story" \
  --data-urlencode "typoTolerance=false" \
  --data-urlencode "numericFilters=created_at_i>${since},points>=15" \
  --data-urlencode "restrictSearchableAttributes=title,url" \
  --data-urlencode "hitsPerPage=30"
```

关键词:
- 调度: `Kubernetes` / `Karpenter` / `KEDA` / `Nomad`
- Serverless: `serverless` / `Lambda` / `Cloud Run` / `Fargate` / `Workers`
- 网络/Mesh: `Envoy` / `Istio` / `Linkerd` / `Cilium` / `eBPF`
- 边缘: `edge computing` / `MEC` / `Cloudflare Workers` / `Fastly Compute`
- 运行时: `WebAssembly runtime` / `containerd` / `Firecracker`

### 3. lobste.rs

```bash
UA="Mozilla/5.0 tech-radar-skill/0.1.0"
curl -sLH "User-Agent: $UA" "https://lobste.rs/t/distributed.json"
curl -sLH "User-Agent: $UA" "https://lobste.rs/t/devops.json"
curl -sLH "User-Agent: $UA" "https://lobste.rs/t/virtualization.json"
```

## 工作流

1. 路由 → 选源(分布式偏 arXiv;k8s/serverless 偏 HN + lobste.rs;边缘 AI 三源都要)
2. 并行拉(arXiv 多查询要串行 + 3s 间隔)
3. URL 去重 + 时间倒序
4. arXiv 摘要翻成中文 + 1-2 句精炼

## 输出格式

```markdown
# 云原生 & 边缘雷达 — 最近 7 天 · 共 N 条

## 论文(arXiv)
1. **<中文翻译标题>** — `arXiv:<id>` · cs.DC
   2 天前
   <1-2 句中文摘要>
   <abs link>

## 工程讨论(Hacker News)
2. **<原标题>** — HN · 215 分 · 130 评论
   3 天前
   <link>

## 社区精选(lobste.rs)
3. **<标题>** — lobste.rs/distributed · 42 分
   昨天
   <link>
```

- 编号全局连续
- arXiv 摘要必翻 + 缩 1-2 句
- 时间转人话

## 不要做

- arXiv 多次查询不能并发(3 秒间隔)
- HN 必带 `typoTolerance=false`(`MEC` 会匹配 "Mac" 等)
- 不展示基础设施细节(API URL / `numericFilters` / objectID)
- 不要把 "AI 推理加速 kernel 优化" 路由到本 skill — 那是 [[tech-radar-ai-infra]];本 skill 只覆盖**部署侧**的边缘推理(调度、网络、低延迟运行时)
- 不要把 "GPU/NVLink/RDMA 硬件" 路由到本 skill — 走 [[tech-radar-hpc-hardware]]
