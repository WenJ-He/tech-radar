---
name: tech-radar-hpc-hardware
description: HPC 与硬件协同优化方向的英文一手源雷达。触发关键词:HPC、高性能计算、超算、supercomputing、HPL、HPCG、CUDA、NVLink、NVSwitch、NVL72、Infiniband、RoCE、RDMA、GPUDirect、tensor core、张量核心、FP4、FP8、INT4、TF32、BF16、混合精度、mixed precision、Hopper、Blackwell、H100、H200、B200、GB200、MI300、MI325、TPU、Trainium、Groq、SambaNova、Cerebras、DGX、DGX Cloud、SuperPod、interconnect、collective communication、NCCL、RCCL、AllReduce、AllGather、ring/tree topology、gpu profiling、Nsight、rocprof、CUDA Graph、HIP、SYCL、oneAPI、ROCm、CUPY、CuTe、CUTLASS、warp specialization、async copy、TMA、Hopper Tensor Memory Accelerator、memory bandwidth、HBM、HBM3e、HBM4、PCIe、CXL、heterogeneous computing、异构计算、parallel algorithm、并行算法、performance modeling、NVIDIA dev blog、Phoronix、Linux 性能、kernel benchmark、Bluesky 硬件圈。当用户问"H200/B200 实测性能"、"NVLink 拓扑"、"FP8 训练实战"、"HPC 论文"、"NCCL 调优"、"NVIDIA 开发者博客"、"Phoronix 最近评测"等任何 HPC / 加速器硬件 / 互联 / 性能分析方向时使用。聚合 arXiv (cs.AR/cs.PF/cs.DC) + Hacker News + lobste.rs/hardware,performance + Bluesky (策展 handles) + NVIDIA Dev Blog RSS + Phoronix RSS 多个免 key 源。
---

# Tech Radar — HPC & 硬件协同

聚焦**加速器硬件本身 + 算子-硬件协同 + 互联拓扑 + 性能工程**。**深度学习编译器侧**(MLIR/TVM/算子融合)走 [[tech-radar-ai-infra]];**云原生调度**走 [[tech-radar-cloud-edge]];本 skill 是**硬件 + 性能**这一层。

## 路由

| 用户在说 | 走哪些源 |
|---|---|
| "HPC / 异构计算 / collective 通信论文" | arXiv cs.AR + cs.PF + cs.DC |
| "H200/B200/MI300 实测"、"CUTLASS 新特性" | HN + lobste.rs |
| "NCCL 调优"、"NVLink 拓扑"、"GPUDirect" | HN + 论文 |
| "FP8 训练实战"(硬件视角) | arXiv + HN |
| **默认(宽问题)** "HPC/加速器硬件最近有啥" | 三源并行 |

## 数据源

### 1. arXiv API

类别速查:
| 类别 | 用途 |
|---|---|
| `cs.AR` | 硬件架构、加速器设计 |
| `cs.PF` | 性能分析、profiling、micro-benchmark |
| `cs.DC` | 分布式 / 并行计算 / 集合通信 |
| `cs.MS` | 数值软件(BLAS/LAPACK 优化) |

```bash
UA="Mozilla/5.0 tech-radar-skill/0.1.0"
curl -sLH "User-Agent: $UA" \
  "http://export.arxiv.org/api/query?search_query=%28cat:cs.AR+OR+cat:cs.PF%29+AND+all:%22FP8%22&sortBy=submittedDate&sortOrder=descending&max_results=20"
```

**多次查询要串行 + ≥ 3 秒间隔**;XML 解析模板见 [[tech-radar-ai-infra]] SKILL.md。

### 2. Hacker News (Algolia)

- 必带 `typoTolerance=false`
- `numericFilters=points>=15`(硬件话题受众小,门槛比 AI 类话题低一些)

```bash
since=$(date -d '7 days ago' +%s)
curl -sG "https://hn.algolia.com/api/v1/search_by_date" \
  --data-urlencode "query=NVLink" \
  --data-urlencode "tags=story" \
  --data-urlencode "typoTolerance=false" \
  --data-urlencode "numericFilters=created_at_i>${since},points>=10" \
  --data-urlencode "restrictSearchableAttributes=title,url" \
  --data-urlencode "hitsPerPage=30"
```

关键词:
- 加速器: `H100` / `H200` / `B200` / `GB200` / `MI300` / `MI325` / `TPU` / `Trainium`
- 互联: `NVLink` / `NVSwitch` / `Infiniband` / `RoCE` / `RDMA` / `GPUDirect`
- 通信库: `NCCL` / `RCCL` / `MPI`
- 性能: `tensor core` / `CUTLASS` / `CuTe` / `TMA` / `warp specialization`
- 数据类型: `FP8` / `FP4` / `TF32` / `BF16` / `INT4`
- 内存: `HBM3` / `HBM3e` / `HBM4` / `CXL`

### 3. lobste.rs

```bash
UA="Mozilla/5.0 tech-radar-skill/0.1.0"
curl -sLH "User-Agent: $UA" "https://lobste.rs/t/hardware.json"
curl -sLH "User-Agent: $UA" "https://lobste.rs/t/performance.json"
curl -sLH "User-Agent: $UA" "https://lobste.rs/t/gpus.json"
```

### 4. Bluesky (策展 handles)

详见 [[tech-radar-ai-infra]] SKILL.md 第 5 节(`getAuthorFeed` 用法)。硬件圈推荐候选(全部待 `resolveHandle` 验证):

| Handle | 内容 |
|---|---|
| `brendangregg.bsky.social` | 性能 / eBPF / flame graph 大佬 |
| `chipsandcheese.bsky.social` | CPU/GPU 微架构评测 |
| `tomshardware.bsky.social` | 硬件评测官号 |
| `anandtech.bsky.social` | 硬件深度文 |

### 5. 官方 RSS

| 源 | RSS | 用途 |
|---|---|---|
| NVIDIA Dev Blog | `https://developer.nvidia.com/blog/feed` | CUDA / TensorRT / Triton / Nsight / cuDNN 深度文 |
| NVIDIA News | `https://blogs.nvidia.com/feed/` | 硬件发布、合作案例 |
| Phoronix | `https://www.phoronix.com/rss.php` | Linux 内核 / 驱动 / 硬件 benchmark |

```bash
curl -sLH "User-Agent: tech-radar-skill/0.1.0" "https://developer.nvidia.com/blog/feed" -o /tmp/nv-dev.xml
curl -sLH "User-Agent: tech-radar-skill/0.1.0" "https://www.phoronix.com/rss.php" -o /tmp/phoronix.xml
# RSS 2.0,Python 标准库 ET 解析(模板见 ai-infra 第 6 节)
```

NVIDIA Dev Blog 历史条目多(100+),必须按 pubDate 倒序 + 时间窗截断到最近 7-14 天。

## 工作流

1. 路由 → 选源(论文偏 arXiv;新硬件评测偏 HN)
2. 并行(arXiv 多查询串行 + 3s)
3. URL 去重 + 时间倒序
4. arXiv 摘要中文翻译 + 1-2 句精炼

## 输出格式

```markdown
# HPC & 硬件雷达 — 最近 7 天 · 共 N 条

## 论文(arXiv)
1. **<中文翻译标题>** — `arXiv:<id>` · cs.AR
   2 天前
   <1-2 句中文摘要>
   <abs link>

## 工程讨论(Hacker News)
2. **<原标题>** — HN · 312 分 · 180 评论
   昨天
   <link>

## 社区精选(lobste.rs)
3. **<标题>** — lobste.rs/hardware · 35 分
   3 天前
   <link>
```

- 编号全局连续
- arXiv 摘要必翻 + 缩 1-2 句
- 时间转人话
- **硬件型号保留英文**(H200/B200/MI300),不要翻成"H 200"等怪写法

## 不要做

- arXiv 多次查询不能并发(3 秒间隔)
- HN 必带 `typoTolerance=false`(`FP8` 会匹配 "fps"、`B200` 会匹配 "2000" 等)
- 不展示 API URL / `numericFilters` / objectID
- **算子优化 / 编译器视角的 FP8 量化**(GPTQ/AWQ 等)走 [[tech-radar-ai-infra]],本 skill 关注硬件能力本身(如"H200 上 FP8 实际带宽");
- **分布式训练的调度策略**(Karpenter/k8s)走 [[tech-radar-cloud-edge]],本 skill 关注通信底层(NCCL/NVLink/RDMA)
- 不要把 HPC 学术会议(SC / ISC / ASPLOS / PPoPP)的"会议消息"当核心信息塞输出 — 关注论文/技术内容本身
