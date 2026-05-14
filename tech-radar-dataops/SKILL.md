---
name: tech-radar-dataops
description: 数据科学与可视化方向的英文一手源雷达。触发关键词:DuckDB、Polars、Apache Arrow、ClickHouse、StarRocks、Doris、Pinot、Druid、Iceberg、Hudi、Delta Lake、Lance、Lance-DB、Parquet、ORC、Avro、columnar storage、列存、lakehouse、数据湖、data lake、数据仓库、data warehouse、OLAP、HTAP、ETL、ELT、dbt、Dagster、Airflow、Prefect、Materialize、Flink、Spark、stream processing、流处理、CDC、change data capture、Debezium、向量数据库、vector database、pgvector、Qdrant、Weaviate、Milvus、ChromaDB、LanceDB、observable、observable framework、Plotly、Vega、D3、Apache ECharts、Grafana、Superset、Metabase、可视化、dashboard、EDA、探索性数据分析、高维数据、IoT 数据、传感器数据、遥感、time-series、时序数据库、TimescaleDB、QuestDB、InfluxDB、Prometheus、自动化报表、自动化分析 pipeline。当用户问"DuckDB 新版本"、"Iceberg vs Hudi"、"向量数据库选型"、"流处理论文"、"Observable Framework 实战"等任何数据栈 / 可视化 / 时序数据方向时使用。聚合 arXiv (cs.DB) + Hacker News + lobste.rs/databases,visualization 三个免 key 源。
---

# Tech Radar — 数据科学 & 可视化

聚焦**数据基础设施(数据库、湖仓、流处理) + 可视化工具 + 时序/IoT 数据栈**。机器学习算法本身走 [[tech-radar-ai-infra]];本 skill 关注**数据进入 ML 之前的存、算、看**这条链路。

## 路由

| 用户在说 | 走哪些源 |
|---|---|
| "数据库 / 列存 / OLAP 论文" | arXiv cs.DB |
| "DuckDB / Polars / ClickHouse 新版本" | HN + lobste.rs/databases |
| "Iceberg vs Hudi vs Delta" 选型 | HN + lobste.rs |
| "向量数据库"、"vector DB benchmark" | HN + 论文 |
| "流处理 / Flink / CDC" | arXiv + HN |
| "Observable / Plotly / dashboard 工具" | HN + lobste.rs/visualization |
| "时序数据库 / TimescaleDB / IoT 数据" | HN + 论文 |
| **默认(宽问题)** "数据栈最近啥新东西" | 三源并行 |

## 数据源

### 1. arXiv API

类别速查:
| 类别 | 用途 |
|---|---|
| `cs.DB` | 数据库、存储引擎、查询优化 |
| `cs.IR` | 信息检索、向量检索 |

```bash
UA="Mozilla/5.0 tech-radar-skill/0.1.0"
curl -sLH "User-Agent: $UA" \
  "http://export.arxiv.org/api/query?search_query=cat:cs.DB+AND+all:%22vector+search%22&sortBy=submittedDate&sortOrder=descending&max_results=20"
```

**多次查询要串行 + ≥ 3 秒间隔**;XML 解析模板见 [[tech-radar-ai-infra]] SKILL.md。

### 2. Hacker News (Algolia)

```bash
since=$(date -d '7 days ago' +%s)
curl -sG "https://hn.algolia.com/api/v1/search_by_date" \
  --data-urlencode "query=DuckDB" \
  --data-urlencode "tags=story" \
  --data-urlencode "typoTolerance=false" \
  --data-urlencode "numericFilters=created_at_i>${since},points>=10" \
  --data-urlencode "restrictSearchableAttributes=title,url" \
  --data-urlencode "hitsPerPage=30"
```

关键词:
- 嵌入式分析: `DuckDB` / `Polars` / `Arrow` / `Lance`
- 列存分析: `ClickHouse` / `StarRocks` / `Doris` / `Pinot` / `Druid`
- 湖仓格式: `Iceberg` / `Hudi` / `Delta Lake` / `Lance`
- 流处理: `Flink` / `Kafka Streams` / `Materialize` / `Debezium`
- 向量数据库: `pgvector` / `Qdrant` / `Weaviate` / `Milvus` / `LanceDB`
- 时序: `TimescaleDB` / `QuestDB` / `InfluxDB` / `VictoriaMetrics`
- 可视化: `Observable` / `Plotly` / `Vega` / `ECharts` / `Superset` / `Metabase`
- 编排: `dbt` / `Dagster` / `Prefect`

### 3. lobste.rs

```bash
UA="Mozilla/5.0 tech-radar-skill/0.1.0"
curl -sLH "User-Agent: $UA" "https://lobste.rs/t/databases.json"
curl -sLH "User-Agent: $UA" "https://lobste.rs/t/visualization.json"
curl -sLH "User-Agent: $UA" "https://lobste.rs/t/datamining.json"
```

## 工作流

1. 路由 → 选源(数据库论文偏 arXiv;工具/版本偏 HN + lobste.rs)
2. 并行(arXiv 多查询串行 + 3s)
3. URL 去重 + 时间倒序
4. arXiv 摘要中文翻译 + 1-2 句精炼
5. 同一产品多源命中(如 DuckDB 在 HN + lobste.rs 都有讨论)按 url 去重保留分数高的那条

## 输出格式

```markdown
# 数据栈 & 可视化雷达 — 最近 7 天 · 共 N 条

## 论文(arXiv)
1. **<中文翻译标题>** — `arXiv:<id>` · cs.DB
   2 天前
   <1-2 句中文摘要>
   <abs link>

## 工程讨论(Hacker News)
2. **<原标题>** — HN · 187 分 · 95 评论
   昨天
   <link>

## 社区精选(lobste.rs)
3. **<标题>** — lobste.rs/databases · 31 分
   3 天前
   <link>
```

- 编号全局连续
- arXiv 摘要必翻 + 缩 1-2 句
- 时间转人话

## 不要做

- arXiv 多次查询不能并发(3 秒间隔)
- HN 必带 `typoTolerance=false`(`Arrow` 会匹配 "narrow"、`Pinot` 会匹配 "spinoff" 等)
- 不展示基础设施细节
- **ML 算法 / LLM 检索增强(RAG)的检索算法本身**走 [[tech-radar-ai-infra]],本 skill 只关注**底层向量数据库系统**(pgvector/Milvus 的引擎实现、benchmark)
- **数据湖跟分布式存储调度**(S3 / HDFS / 集群伸缩)走 [[tech-radar-cloud-edge]],本 skill 关注表格式 + 查询引擎
- 不要把"BI 工具公司新闻 / 财报"塞进输出 — 关注技术与版本变更
