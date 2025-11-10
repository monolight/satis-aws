FROM composer/satis:latest

# Install AWS CLI
# Alpine Linux uses apk package manager
# AWS CLI requires Python3 and pip
# Use --break-system-packages flag as this is an isolated container environment
RUN apk add --no-cache \
    python3 \
    py3-pip \
    && pip3 install --no-cache-dir --break-system-packages awscli \
    && rm -rf /var/cache/apk/*

# Configure git for AWS CodeCommit
# UseHttpPath is required for CodeCommit authentication
RUN git config --global credential.UseHttpPath true

# Note: credential.helper will be configured at runtime with actual AWS credentials
# This ensures git is ready to use AWS CodeCommit credential helper

