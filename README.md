# PgBouncer Helm Chart
I've tried more than a few charts, but none seemed to work for me. So I've created this one.

This is a standalone PgBouncer chart extracted from the one embedded in [Airflow](https://github.com/apache/airflow) chart.

## Prerequisites

- Kubernetes 1.12+
- Helm 3.0+

## Installation

To install the chart with the release name `my-pgbouncer`:

```bash
helm upgrade -i my-pgbouncer oci://registry-1.docker.io/ulevitsky/pgbouncer
```

This command deploys a PgBouncer instance with default configuration.

## Requirements

Kubernetes: `>= 1.20.0-0`

