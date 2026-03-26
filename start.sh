#!/bin/bash
set -e

# Setup Claude auth from env vars if provided
if [ -n "$CLAUDE_AUTH_TOKEN" ] && [ -n "$CLAUDE_REFRESH_TOKEN" ]; then
  cat > /root/.claude/.credentials.json << CREDS
{
  "claudeAiOauth": {
    "accessToken": "$CLAUDE_AUTH_TOKEN",
    "refreshToken": "$CLAUDE_REFRESH_TOKEN",
    "expiresAt": ${CLAUDE_TOKEN_EXPIRES:-1774277003256},
    "scopes": ["user:file_upload","user:inference","user:mcp_servers","user:profile","user:sessions:claude_code"],
    "subscriptionType": "pro",
    "rateLimitTier": "default_claude_ai"
  },
  "organizationUuid": "${CLAUDE_ORG_UUID:-2ad76a5b-c418-4f9b-9a6a-02b5db343954}"
}
CREDS
  echo "Claude credentials configured from env vars"
fi

# Create tmux config
cat > /root/.tmux.conf << 'TMUX'
set -g mouse on
set -g history-limit 50000
set -g default-terminal "xterm-256color"
TMUX

# Start ttyd with auth, serving a tmux session
# On connect: attach to existing session or create new one
exec ttyd \
  --port 7682 \
  --writable \
  --reconnect 30 \
  -c "${TTYD_USER:-karma}:${TTYD_PASS:-KarmaOps2026}" \
  -t fontSize=14 \
  -t 'theme={"background":"#0F0F0F","foreground":"#e0e0e0","cursor":"#7C3AED"}' \
  bash -c 'tmux has-session -t claude 2>/dev/null && tmux attach -t claude || tmux new-session -s claude -c /root/workspace'
