# Kazoo Lab Environment

This repository provides a Docker-based laboratory environment for Kazoo, an open-source cloud telecom platform. It includes a complete setup with FreeSWITCH, Kamailio, RabbitMQ, CouchDB, and monitoring tools for development and testing purposes.

## Prerequisites

- Docker and Docker Compose
- Make utility

## Quick Start

```bash
# Create and initialize the environment
make create
make init

# Start all services
make start

# Check status
make ps
```

## Available Commands

### Setup and Initialization

```bash
# Create the environment (sets up configuration and Docker containers)
make create

# Initialize the environment (starts services and waits for device registrations)
make init

# Reinitialize Kazoo and CouchDB containers (useful for database reset)
make reinit

# Wait for device registrations
make wait-for-regs
```

### Operation Commands

```bash
# Start all services in foreground mode with logs
make run

# Start all services in background mode
make start

# Stop all services
make stop

# Remove all containers and environment files (.env, .env.yaml)
make rm

# Show status of running containers
make ps

# Clean up Docker resources (remove images and volumes)
make docker-prune
```

### Testing Commands

```bash
# Run the default test (internal-calls)
make test

# Run a specific test
make test TEST=internal-calls

# Originate a test call from a device
make device/originate

# Customize call parameters
make device/originate FROM=ext1000 TO=1001 CONTEXT=inbound CALLBACK=play
```

### Connection Commands

```bash
# Connect to FreeSWITCH devices container with fs_cli
make connect/fs-devices

# Connect to any container with bash shell
make connect/kz
make connect/amqp
make connect/couchdb
# etc.
```

## Project Structure

```
├── compose.yaml         # Main Docker Compose configuration
├── etc/                 # Configuration files for services
├── make/                # Makefile includes
│   ├── env.mk           # Environment setup commands
│   └── images.mk        # Docker image management commands
├── src/                 # Source files for Docker services
│   ├── images/          # Dockerfiles for building images
│   ├── networks.yaml    # Network configuration
│   ├── roles/           # Role definitions for services
│   └── services/        # Service configurations
└── tests/               # Test definitions
```

## Components

The environment includes:
- Kazoo applications (call processing platform)
- FreeSWITCH instances (devices and PSTN simulation)
- Kamailio SIP proxy (SIP routing)
- RabbitMQ for messaging (AMQP)
- CouchDB for data storage
- Prometheus and Grafana for monitoring
- Syslog for centralized logging

## Development

For development purposes, you can use:
```bash
# Access development shell
make dev
```

## Environment Variables

The following environment variables can be configured to customize your environment:

### Build Configuration
- `PROJECT`: The project name for Docker containers and networks (defaults to 'kazoo')

### Deployment Configuration
- `ADD_HOSTS`: Additional Kazoo hosts to deploy (optional)
- `KZ_SRC`: Path to Kazoo source code (optional, enables development mode)

### Call Testing Configuration
- `FROM`: Source extension for test calls (default: ext1000)
- `TO`: Destination extension for test calls (default: 1001)
- `CONTEXT`: Call context (default: inbound)
- `CALLBACK`: Call handling method (default: play)
- `CALL_VARS`: Additional call variables (default: absolute_codec_string=PCMU)

### Performance Testing
- `CPS`: Calls per second for load testing (default: 15)
- `MAX_CALLS`: Maximum concurrent calls (default: 10)
- `TOTAL_CALLS`: Total number of calls to generate (default: 100)

These variables can be set in your environment before running make commands or configured in the `.env` file.
