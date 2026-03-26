FROM node:22-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    tmux git curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install ttyd from GitHub releases (not in Debian repos)
RUN curl -sL https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 -o /usr/local/bin/ttyd && \
    chmod +x /usr/local/bin/ttyd

RUN npm install -g @anthropic-ai/claude-code

RUN useradd -m -s /bin/bash karmabyte

COPY start.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER karmabyte
WORKDIR /home/karmabyte

EXPOSE 7682

ENTRYPOINT ["/entrypoint.sh"]
