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