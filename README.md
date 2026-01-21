
# Bytehawks n8n Custom Build

This repository contains a custom build of [n8n](https://n8n.io/) by Bytehawks, featuring extended Python support and additional tools for advanced automation.

## Main Features

- **Based on n8n v2.3.6**
- **Python support**: Pre-installed virtual environment with useful packages for automation, scraping, image processing, AWS, Git, and more.
- **Custom certificates**: Automatic handling of custom certificates via `/opt/custom-certificates`.
- **Additional packages**: curl, git, ffmpeg, zip, openssh-client, pandoc, Noto fonts, and more.
- **Custom entrypoint**: Flexible n8n startup and certificate management.

## How to Build the Image

```sh
docker build -t bytehawks/n8n:{TAG} .
```

## How to Run the Container

```sh
docker run -it --rm -p 5678:5678 bytehawks/n8n:{TAG}
```

To pass custom arguments (e.g. worker):

```sh
docker run -it --rm bytehawks/n8n:{TAG} worker
```

## Custom Certificate Management

To add custom certificates, mount a folder to `/opt/custom-certificates`:

```sh
docker run -v /path/to/certs:/opt/custom-certificates ...
```

## Included Python Packages

The following packages are pre-installed in the Python virtual environment:

- markdownify
- pypandoc
- beautifulsoup4
- lxml
- requests
- Pillow
- boto3
- GitPython
- setuptools
- wheel

## File Structure

- `Dockerfile`: multi-stage build, n8n installation, tools, and Python
- `docker-entrypoint.sh`: n8n startup and certificate management
- `requirements.txt`: installed Python packages

## Author

Matteo Kutufa (<mk@bytehawks.org>)

---

**License:** Apache-2.0

**Source:** https://github.com/bytehawks-org/n8n
