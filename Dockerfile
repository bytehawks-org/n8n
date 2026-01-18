
# Definiamo la versione target
ARG N8N_VERSION=2.3.6
ARG IMAGE_VERSION=${N8N_VERSION}
ARG NODE_VERSION=22

# ==========================================
# STAGE 1: Builder
# ==========================================
# Usiamo Node 22 Alpine come l'originale
FROM node:${NODE_VERSION}-alpine AS builder

WORKDIR /tmp

# Installiamo i tool di compilazione necessari per le dipendenze native di n8n
# (Questi servono solo per installare, poi li buttiamo via)
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    build-base \
    cairo-dev \
    pango-dev \
    jpeg-dev \
    giflib-dev \
    librsvg-dev

# Installazione pulita di n8n
RUN npm install -g n8n@${N8N_VERSION} --unsafe-perm --production

# ==========================================
# STAGE 2: Final Image (Specular to Community)
# ==========================================
FROM node:${NODE_VERSION}-alpine

# Metadata standard OCI
LABEL org.opencontainers.image.title="Bytehawks n8n custom image with Python Support"
LABEL org.opencontainers.image.description="n8n ${N8N_VERSION} customized by ByteHawks. BH Version ${IMAGE_VERSION}"
LABEL org.opencontainers.image.authors="Matteo Kutufa <mk@bytehawks.org>"
LABEL org.opencontainers.image.source="https://github.com/bytehawks-org/n8n"
LABEL org.opencontainers.image.version="${IMAGE_VERSION}"
LABEL org.opencontainers.image.licenses="Apache-2.0"

# ENV standard di n8n
ENV NODE_ENV=production
ENV N8N_PORT=5678
ENV N8N_USER_ID=1000
ENV N8N_Editor_Is_Session_Based=true

# Setup directory
RUN mkdir -p /home/node/.n8n /home/node/n8n-data && \
    chown -R node:node /home/node/.n8n /home/node/n8n-data

# Script di entrypoint (vedi sotto, è fondamentale)
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

WORKDIR /home/node/n8n-data

# --- INSTALLAZIONE PACCHETTI ---
# 1. Pacchetti CORE (Identici alla Community Image):
#    - tini: gestore processi (init)
#    - su-exec: gestione permessi utente
#    - graphicsmagick: manipolazione immagini
#    - tzdata: gestione timezone
#    - font-noto-*: set di font per evitare rettangolini al posto del testo nelle immagini generate
# 2. Pacchetti CUSTOM (I tuoi):
#    - Qui aggiungi quello che manca (es. curl, git, ffmpeg, zip, etc.)
RUN apk add --no-cache \
    tini \
    su-exec \
    graphicsmagick \
    tzdata \
    font-noto \
    font-noto-emoji \
    font-noto-cjk \
    openssh-client \
    openssl \
    python3 \
    py3-pip \
    pandoc \
    git \
    bash \
    curl \
    wget \
    build-base \
    jpeg-dev \
    zlib-dev \
    libxml2-dev \
    libxslt-dev \
    ca-certificates

# Copia n8n compilato dal builder
COPY --from=builder /usr/local/lib/node_modules /usr/local/lib/node_modules
#COPY --from=builder /usr/local/bin/n8n /usr/local/bin/n8n
RUN ln -s /usr/local/lib/node_modules/n8n/bin/n8n /usr/local/bin/n8n



ENV VIRTUAL_ENV=/home/node/.venv
RUN python3 -m venv $VIRTUAL_ENV && \
    chown -R node:node $VIRTUAL_ENV

USER node

ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY --chown=node:node requirements.txt ${VIRTUAL_ENV}/requirements.txt

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r ${VIRTUAL_ENV}/requirements.txt

EXPOSE 5678

VOLUME ["/home/node/.n8n", "/home/node/n8n-data"]

ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint.sh"]
CMD ["n8n"]


