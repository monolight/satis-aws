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
- Git configured to use AWS CodeCommit credential helper (required when running as non-root user)
- Repositories in `satis.json` configured with `"type": "git"` (not `"type": "vcs"`)

**Important Notes:**
- The Dockerfile pre-configures git for root user, but when running as a non-root user (`--user`), you need to configure git at runtime
- Set `HOME=/build/.docker-home` environment variable so the non-root user has a writable home directory for git config
- Set `COMPOSER_HOME=/build/.docker-home/.composer` so Composer can create its cache directory
- CodeCommit repositories must be explicitly set as `"type": "git"` in satis.json to prevent Composer from using SvnDriver
- The `.docker-home` directory will be created in your project directory (where you mount `/build`)

Example with non-root user:
```bash
docker run --rm \
  --user $(id -u):$(id -g) \
  -v $(pwd):/build \
  -w /build \
  -e HOME=/build/.docker-home \
  -e COMPOSER_HOME=/build/.docker-home/.composer \
  -e AWS_ACCESS_KEY_ID=your-access-key \
  -e AWS_SECRET_ACCESS_KEY=your-secret-key \
  -e COMPOSER_AUTH='{"github-oauth":{"github.com":"your-token"}}' \
  ghcr.io/monolight/satis-aws:latest \
  sh -c "mkdir -p /build/.docker-home && \
         git config --global credential.helper '!aws codecommit credential-helper $@' && \
         git config --global credential.UseHttpPath true && \
         /satis/bin/satis build satis.json output"
```

**Note:** When using `sh -c`, you must use the full path `/satis/bin/satis` because the entrypoint script (which normally handles `satis` commands) is bypassed. When running as root without `sh -c`, you can use `satis` directly as the entrypoint will handle it.

Example as root (simpler, but less secure):
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

## Responsible Disclosure

This project was generated mostly by AI under human supervision. While efforts have been made to ensure correctness and security, please review the code carefully before use in production environments. If you discover any bugs, security issues, or vulnerabilities, please report them responsibly through the project's issue tracker.

