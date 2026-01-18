# By default we set N8N_VERSION to 2.3.6, but you can override it during build time
ARG N8N_VERSION=2.3.6
ARG IMAGE_VERSION=${N8N_VERSION}

FROM n8nio/n8n:${N8N_VERSION}

# Metadata standard OCI
LABEL org.opencontainers.image.title="Bytehawks n8n custom image with Python Support"
LABEL org.opencontainers.image.description="n8n ${N8N_VERSION} customized by ByteHawks. BH Version ${IMAGE_VERSION}"
LABEL org.opencontainers.image.authors="Matteo Kutufa <mk@bytehawks.org>"
LABEL org.opencontainers.image.source="https://github.com/bytehawks-org/n8n"
LABEL org.opencontainers.image.version="${IMAGE_VERSION}"
LABEL org.opencontainers.image.licenses="Apache-2.0"

USER root

RUN apk add --update --no-cache \
    python3 \
    py3-pip \
    py3-venv \
    pandoc \
    git \
    bash \
    curl \
    wget \
    build-base \
    jpeg-dev \
    zlib-dev \
    libxml2-dev \
    libxslt-dev && \
    ln -sf /usr/bin/python3 /usr/bin/python

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV && \
    chown -R node:node $VIRTUAL_ENV

USER node

ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY --chown=node:node requirements.txt ${VIRTUAL_ENV}/requirements.txt

RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r ${VIRTUAL_ENV}/requirements.txt
