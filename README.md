I'll create a README.md that serves as a comprehensive guide to the FerretDB evaluation setup:

```markdown
# FerretDB Evaluation Environment

## Overview

This project provides a Docker-based evaluation setup for FerretDB, inspired by the official [FerretDB Evaluation Documentation](https://docs.ferretdb.io/installation/evaluation/).

## Prerequisites

- Docker
- Just (command runner)

## Justfile Workflow Cheatsheet

### Basic Commands

```bash
# List available commands
just

# Setup FerretDB environment
just setup

# Run all tests
just test

# Tear down the environment
just teardown
```

### Detailed Command Breakdown

| Command | Description |
|---------|-------------|
| `just setup` | Create Docker network and start FerretDB container |
| `just teardown` | Stop FerretDB container and remove Docker network |
| `just test` | Run comprehensive tests including: |
|  | - Connectivity check |
|  | - Document insertion |
|  | - Document querying |
|  | - CRUD operations |
| `just test-connect` | Verify basic MongoDB connectivity |
| `just test-insert` | Insert a test document |
| `just test-query` | Query inserted documents |
| `just test-crud` | Run comprehensive CRUD test suite |
| `just shell` | Open interactive MongoDB shell |
| `just psql` | Open interactive PostgreSQL shell |

### Example Workflows

```bash
# Setup environment and run tests
just setup test

# Teardown and restart
just teardown setup

# Run only specific tests
just test-insert
just test-query
```

## Troubleshooting

- Ensure Docker is running before executing commands
- Check network connectivity if tests fail
- Verify Docker permissions

## Connection Details

- **MongoDB Connection String**: `mongodb://username:password@localhost:27017/testdb`
- **Platform**: `linux/amd64`
- **Container Image**: `ghcr.io/ferretdb/ferretdb-eval:2`

