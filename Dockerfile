# PolkaDot/ArgonChain Validator Node Build Dockerfile
# Author: BuzaG
# License: Apache 2.0
# Description: This Dockerfile sets up the ArgonChain Validator Node application with necessary configurations and environment variables.

# Use the official Rust image for the build stage
FROM rust:latest AS build

# Install additional dependencies required for building
RUN apt update && apt upgrade -y && \
    apt install -y clang curl git libssl-dev llvm libudev-dev protobuf-compiler jq

WORKDIR /app
COPY . .

# Add the nightly toolchain and WASM target in a single step
RUN rustup update nightly && \
    rustup target add wasm32-unknown-unknown --toolchain nightly

# Build the project in release mode
RUN cargo build --release

# Update minervaRaw.json
RUN chmod +x ./update_bootnodes.sh && ./update_bootnodes.sh

# Use a minimal Debian-based image for the production stage
FROM debian:latest AS prod

LABEL org.opencontainers.image.author="BuzaG" \
      org.opencontainers.image.description="ArgoChain Validator Node" \
      org.opencontainers.image.version="0.1"

# Install necessary runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends curl jq libssl3 ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the necessary build artifacts from the build stage
COPY --from=build /app/target/release/argochain /app/argochain
COPY --from=build /app/minervaRaw.json /app/minervaRaw.json

# Prepare the necessary scripts and set executable permissions
COPY /Docker/init-and-run.sh /Docker/rotate_keys_docker.sh ./
RUN chmod +x init-and-run.sh rotate_keys_docker.sh argochain

# Create the /argochain directory
RUN mkdir -p /argochain/base /argochain/keystore

# Expose necessary ports
EXPOSE 30333 9944

# Default command to run the application using sh
CMD ["/bin/sh", "/app/init-and-run.sh", "$NODE_NAME"]