# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repository is a personal knowledge base for conference talks by a Principal Software Engineer in the Apicurio community. It tracks talk abstracts and conference acceptances.

## Repository Structure

- **`talks/`** — Each subdirectory contains one talk topic with text files holding the abstract/description. A talk may have multiple files (e.g., `description.txt`, `benefit-ecosystem.txt`) covering different angles of the same topic.
- **`conferences/`** — Tracks which conferences accepted which talks. The `talk` file maps accepted talk names to conference URLs/details.

## Talk Topics

The talks revolve around the Apicurio ecosystem and related open-source technologies (Kafka, Strimzi, Debezium, Keycloak, Quarkus, Spark). Current topics include:
- AI agent discovery and registry (A2A Protocol, Apicurio Registry)
- Open-source community maintenance
- CDC/event-driven architectures (edge-to-cloud pipelines)
- Security integration (Keycloak + Strimzi + Apicurio)
- Real-time stream classification with ML on Kubernetes

## Conventions

- Talk abstracts are plain `.txt` files, not Markdown.
- Directory names use kebab-case (e.g., `stream-prediction`, `agent-discovery`).
- The `conferences/talk` file uses a simple format: talk identifier on one line, conference URL on the next.
