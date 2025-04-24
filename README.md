# Balzac Documentation
[![Python application](https://github.com/balzac-lang/balzac-doc/actions/workflows/python-app.yml/badge.svg)](https://github.com/balzac-lang/balzac-doc/actions/workflows/python-app.yml)

## Overview

This repository contains the official documentation for the Balzac programming language. Balzac is a domain-specific language designed for writing Bitcoin smart contracts. The documentation is built using Sphinx and provides comprehensive information about the language's syntax, features, and usage.

## Quick Start

### Prerequisites

- Python 3.x
- pip (Python package manager)

### Installation

1. Clone this repository:
```bash
git clone https://github.com/balzac-lang/balzac-doc.git
cd balzac-doc
```

2. Install dependencies:
```bash
pip install sphinx pygments
```

3. Install the Balzac lexer and build the documentation:
```bash
make full-build
```

4. Start a local server to view the documentation:
```bash
make server
```

The documentation will be available at http://localhost:8000

## Building the Documentation

### Available Commands

Run `make` to see all available commands. Here are the most commonly used ones:

```bash
make build                # Build the documentation
make clean                # Clean the documentation
make html                 # Build HTML documentation
make latexpdf             # Build PDF documentation
make linkcheck            # Check all external links
```

For a complete list of available commands, run `make` without arguments.

## Docker Support

### Building the Docker Image

Build the Docker image (assuming the documentation is in `build/html`):

```bash
docker build -t balzaclang/balzac-doc:latest .
```

### Running the Documentation Server

Run the container on port 8080:

```bash
docker run --rm --name balzac-doc -p 8080:80 balzaclang/balzac-doc:latest
```

Access the documentation at http://localhost:8080

### Using Prebuilt Images

Pull the latest image from DockerHub:

```bash
docker pull balzaclang/balzac-doc:latest
```

Available architectures:
- linux/amd64
- linux/arm/v7
- linux/arm64

## Contributing

We welcome contributions to the documentation! Please feel free to submit issues or pull requests to help improve the documentation.


## Resources

- [Balzac Language Repository](https://github.com/balzac-lang/balzac)
- [Online Editor](http://blockchain.unica.it/balzac/)
