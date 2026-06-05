# AGENTS Guidelines - SpecAtlas

This repository contains a web application for a reference to technical specifications, detailed by a neo4j graph database.
When working on this project, please follow the following guidelines to ensure the consistency of the development experience.

## Repository Structure

``` text
SpecAtlas/
├── docs/                         # Project-wide documentation; textual documentation should be in GitHub Flavored Markdown.
│   ├── samples/                  # Code samples, in various languages.
│   └── schema/                   # Graph database schema, captured in Mermaid ER diagrams.
├── graphDB                       # Files related to loading or maintaining the graph database.
│   ├── dataload/                 # Cypher scripts related to loading data into the graph database.
│   └── source/                   # Source data files in CSV format for import.
└── web                           # Files related to the web application.
```

## Tech Stack

- **Data Layer**: Neo4j Aura
  - **Data Management Language**: Cypher v25
- **Core Languages**: JavaScript/TypeScript with ES6+ features
- **Platform**: Azure Static Web Sites

## Documentation Requirements

1. Standalone documentation files must be written in GitHub Flavored Markdown (`.md`). Linting rules using the `markdownlint`
   tool are located in the `.markdownlint.jsonc` and `.markdownlint-cli2.jsonc` in the repository root.

2. It is preferable for necessary diagrams to be captured using Mermaid where possible. Smaller diagrams directly related
   to text documentation are included within Markdown code blocks. Large or detailed diagrams are separated out to
   Mermaid (`.mmd`) files. Custom diagrams, where using Mermaid is infeasible, may be created using drawio files.

## General Code Conventions

1. Use 2 spaces for indention.
2. Limit line lengths to 120 characters to enhance readability, wrap lines based on code clauses or blocks.
3. Align declarations by columns, with variable names and assignment sign (`=`) aligned.
4. Code should be self-documenting with clear identifiers and function calling patterns; use idiomatic styles for each
   language for name styling (e.g., camelCase, snake_case, etc.).

## GraphDB Conventions

1. Neo4j data models must be enforced via graph type declarations.

## Web Code Conventions

1. Prefer TypeScript (`.tsx`/`.ts`) for new components or utilities.
