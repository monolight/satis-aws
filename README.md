# Satis AWS Docker Image

A custom Docker image based on [composer/satis](https://github.com/composer/satis) with AWS CLI pre-installed for AWS CodeCommit authentication.

## Overview

This Docker image extends the official Satis image (`composer/satis`) and adds:
- AWS CLI for AWS CodeCommit authentication
- Git configuration for CodeCommit (UseHttpPath enabled)

## Image Location

The image is available at:
```
ghcr.io/monolight/satis-aws:latest
```

## Usage

### Basic Usage

```bash
docker run --rm \
  -v $(pwd):/build \
  -w /build \
  -e AWS_ACCESS_KEY_ID=your-access-key \
  -e AWS_SECRET_ACCESS_KEY=your-secret-key \
  -e COMPOSER_AUTH='{"github-oauth":{"github.com":"your-token"}}' \
  ghcr.io/monolight/satis-aws:latest \
  build satis.json output
```

### With AWS CodeCommit

The image is configured to work with AWS CodeCommit repositories. Ensure you have:
- AWS credentials set via environment variables (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`)
- Git configured to use AWS CodeCommit credential helper (configured at runtime)

Example:
```bash
docker run --rm \
  --user $(id -u):$(id -g) \
  -v $(pwd):/build \
  -w /build \
  -e AWS_ACCESS_KEY_ID=your-access-key \
  -e AWS_SECRET_ACCESS_KEY=your-secret-key \
  -e COMPOSER_AUTH='{"github-oauth":{"github.com":"your-token"}}' \
  ghcr.io/monolight/satis-aws:latest \
  build satis.json output
```

### Configure Git for CodeCommit

When running the container, configure git to use AWS CodeCommit credential helper:

```bash
docker run --rm \
  --user $(id -u):$(id -g) \
  -v $(pwd):/build \
  -w /build \
  -e AWS_ACCESS_KEY_ID=your-access-key \
  -e AWS_SECRET_ACCESS_KEY=your-secret-key \
  ghcr.io/monolight/satis-aws:latest \
  sh -c "git config --global credential.helper '!aws codecommit credential-helper $@' && \
         git config --global credential.UseHttpPath true && \
         satis build satis.json output"
```

## Building the Image

### Local Build

```bash
docker build -t ghcr.io/monolight/satis-aws:latest .
```

### GitHub Actions

The image is automatically built and pushed to GitHub Container Registry via GitHub Actions when:
- Dockerfile changes are pushed to the main branch
- Manual workflow dispatch
- Source image (`composer/satis:latest`) is updated (checked daily)

## Source Image Updates

The repository includes a GitHub Actions workflow that:
- Runs daily at 2 AM UTC
- Checks if the source image (`composer/satis:latest`) has been updated
- Automatically triggers a rebuild if the source image changed

## Requirements

- Docker
- AWS credentials (for CodeCommit authentication)
- GitHub token (for GitHub repositories, if needed)

## License

MIT License - see [LICENSE](LICENSE) file for details.

