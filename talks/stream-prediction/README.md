# Real-Time Reddit Classification Pipeline — Demo Walkthrough

This walkthrough accompanies the **stream-prediction** talk. It demonstrates a fully open-source, end-to-end system for real-time content classification deployed on Kubernetes.

The demo code lives in the [reddit-realtime-classification](reddit-realtime-classification/) directory.

## Architecture

```
Reddit API ──► Kafka Producer ──► Kafka (Strimzi) ──► Spark Streaming ──► Kafka ──► Quarkus Consumer
                                       │                  │                              │
                                  Apicurio Registry   Dual-Model ML              HTML Dashboards
                                 (Schema Governance)  (DistilBERT +              + REST API
                                                       scikit-learn)
                                                                            Jaeger ◄── OTel ──► Prometheus ──► Grafana
```

## Prerequisites

1. A Kubernetes cluster (Minikube, Kind, or OpenShift)
2. [Strimzi Operator](https://strimzi.io/quickstarts/) installed
3. [Spark Operator](https://github.com/kubeflow/spark-operator) installed
4. Reddit API credentials from https://www.reddit.com/prefs/apps
5. `kubectl` configured and authenticated


## Step 1: Deploy Kafka Infrastructure

Install the Strimzi operator and deploy a Kafka cluster using KRaft mode (no ZooKeeper):

```bash
kubectl create namespace reddit-realtime

# Install Strimzi operator
kubectl apply -f https://strimzi.io/install/latest?namespace=reddit-realtime -n reddit-realtime

# Deploy Kafka cluster
kubectl apply -f reddit-realtime-classification/runtime/kafka/kafka_cluster.yaml -n reddit-realtime

# Create topics
kubectl apply -f reddit-realtime-classification/runtime/kafka/producer/incoming_topic.yaml -n reddit-realtime
kubectl apply -f reddit-realtime-classification/runtime/kafka/consumer/outgoing_topic.yaml -n reddit-realtime
kubectl apply -f reddit-realtime-classification/runtime/kafka/dlq-topics.yaml -n reddit-realtime
```

Wait for the Kafka cluster to be ready:
```bash
kubectl wait --for=condition=Ready kafka/reddit-posts -n reddit-realtime --timeout=300s
```


## Step 2: Deploy Apicurio Registry (Schema Governance)

Deploy Apicurio Registry and register the input/output schemas:

```bash
kubectl apply -f reddit-realtime-classification/runtime/registry/apicurio-registry.yaml -n reddit-realtime
kubectl wait --for=condition=Available deployment/apicurio-registry -n reddit-realtime --timeout=120s

# Register schemas with BACKWARD compatibility
kubectl port-forward svc/apicurio-registry 8081:8080 -n reddit-realtime &
cd reddit-realtime-classification && ./schemas/register-schemas.sh && cd ..
```

**Demo point:** Open the Apicurio Registry UI at http://localhost:8081 and show the registered schemas:
- `reddit-stream-value` — input schema (id, content)
- `kafka-predictions-value` — output schema (dual model predictions)

Highlight the BACKWARD compatibility rule — new schema versions must remain compatible.


## Step 3: Deploy Observability Stack

```bash
kubectl apply -f reddit-realtime-classification/runtime/observability/jaeger.yaml -n reddit-realtime
kubectl apply -f reddit-realtime-classification/runtime/observability/prometheus.yaml -n reddit-realtime
kubectl apply -f reddit-realtime-classification/runtime/observability/grafana.yaml -n reddit-realtime
kubectl apply -f reddit-realtime-classification/runtime/observability/grafana-dashboards.yaml -n reddit-realtime
```


## Step 4: Store Reddit API Credentials

```bash
kubectl create secret generic reddit-api-credentials \
  --from-literal=client-id=YOUR_CLIENT_ID \
  --from-literal=client-secret=YOUR_CLIENT_SECRET \
  -n reddit-realtime
```


## Step 5: Deploy the Pipeline

Deploy all components:

```bash
# Model metadata validation service
kubectl apply -f reddit-realtime-classification/runtime/model-metadata/model-metadata.yaml -n reddit-realtime

# Spark dual-model inference job
kubectl apply -f reddit-realtime-classification/runtime/spark/reddit_flair_spark_inference.yaml -n reddit-realtime

# Reddit API producer
kubectl apply -f reddit-realtime-classification/runtime/kafka/producer/reddit_posts_processor.yaml -n reddit-realtime

# Quarkus consumer with dashboards
kubectl apply -f reddit-realtime-classification/runtime/kafka/consumer/flair_consumer.yaml -n reddit-realtime
```


## Step 6: Access the Dashboards

Port-forward to the services:

```bash
# HTML dashboards (built into the Quarkus consumer)
kubectl port-forward svc/predictions-consumer 8080:80 -n reddit-realtime

# Grafana
kubectl port-forward svc/grafana 3000:3000 -n reddit-realtime

# Jaeger distributed tracing
kubectl port-forward svc/jaeger 16686:16686 -n reddit-realtime
```


## Using the Demo

### Show Real-Time Classification

1. Open http://localhost:8080/metrics.html — the main dashboard shows flair distributions updating every 10 seconds as Reddit posts flow through the pipeline.

2. **Tail the producer logs** to show posts being ingested:
   ```bash
   kubectl logs -f deployment/kafka-producer -n reddit-realtime
   ```
   Point out: W3C TraceContext injection in Kafka headers, exponential backoff on errors, DLQ fallback.

3. **Watch Spark processing:**
   ```bash
   kubectl logs -f sparkapplication/spark-reddit-inference -n reddit-realtime
   ```
   Highlight: Structured Streaming micro-batches, dual-model UDF running DistilBERT + scikit-learn in parallel.

### Explore the Dashboards

Navigate through the 7 built-in HTML dashboards:

| Dashboard | URL | What It Shows |
|---|---|---|
| Flair Distribution | `/metrics.html` | Bar charts of flair counts per model, confidence gaps, agreement rates |
| Confusion Matrix | `/confusion-matrix.html` | 13x13 heatmap: Transformer vs sklearn predictions |
| Confidence Distribution | `/confidence-distribution.html` | Histograms of prediction confidence for each model |
| Agreement Over Time | `/agreement-over-time.html` | Line chart of daily model agreement rate |
| Flair Drift | `/flair-drift.html` | Stacked bars showing category distribution shifts |
| Model Uncertainty | `/model-uncertainty.html` | Pie chart: Both Confident / Both Uncertain / Disagreement |
| System Load | `/system-load.html` | Throughput, error rate, latency (p50/p95/p99) |

### Query the REST API

```bash
# Flair statistics per model
curl http://localhost:8080/flairs/statistics | jq

# Confusion matrix (transformer vs sklearn)
curl http://localhost:8080/flairs/confusion-matrix | jq

# Timeline of flair distribution
curl http://localhost:8080/flairs/timeline | jq
```

### Trace a Single Post (Jaeger)

1. Open Jaeger at http://localhost:16686
2. Select service `reddit-producer` and click **Find Traces**
3. Click any trace to see the end-to-end journey:
   - `reddit-api-search` → `produce-reddit-post` → `dual-model-inference` → `transformer-inference` + `sklearn-inference`
4. Show how W3C TraceContext correlates spans across Python producer → Spark → Quarkus consumer

### Grafana Dashboards

Open http://localhost:3000 (admin/admin):
- Pre-provisioned dashboards show real-time line graphs from Prometheus
- Key metrics: `flair_messages_total`, `model_agreement_rate`, `pipeline_messages_total`


## Key Talking Points

1. **Dual-model inference** — Running DistilBERT and scikit-learn in parallel provides reliability without ground truth. The confusion matrix and agreement metrics let you detect model drift.
2. **Schema governance** — Apicurio Registry enforces BACKWARD compatibility on the Kafka schemas. Evolving the prediction format won't break downstream consumers.
3. **Resilience** — Dead Letter Queues at every stage (producer, Spark, consumer), backpressure control via `maxOffsetsPerTrigger`, and health checks on every component.
4. **Observability** — End-to-end distributed tracing with OpenTelemetry, Prometheus metrics, and Grafana dashboards. Every message can be traced from Reddit API to final prediction.
5. **100% open source** — Strimzi, Spark, Apicurio Registry (CNCF sandbox), Quarkus, Prometheus, Grafana, Jaeger — all running on Kubernetes.
