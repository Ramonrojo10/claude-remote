FROM node:20-slim

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    tmux \
    ttyd \
    git \
    curl \
    ca-certificates \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Create workspace
RUN mkdir -p /root/workspace /root/.claude

# Startup script
COPY start.sh /root/start.sh
RUN chmod +x /root/start.sh

EXPOSE 7682

CMD ["/root/start.sh"]
