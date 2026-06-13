---
title: Tech Stack
order: 100
---

# Tech Stack

The technical stack for SpecAtlas is built using a number of core technologies.

## Data Layer

The data layer of SpecAtlas is built as a directed graph database.

Technically, this is implemented as a [Neo4j](https://neo4j.com) database. The database schema is enforced via property
type, existence, and uniqueness constraints across all node and relationship types.

Initial data loading was achieved via import of CSVs using Cypher scripts.

Currently, the web interface for SpecAtlas is limited to read-only operations. Future development includes enabling
community contributions to the database.

## Web Layer

The web application for SpecAtlas is a Next.js application. Supporting technologies include:

- Mermaid.js diagramming
- react-markdown for rendering documentation
