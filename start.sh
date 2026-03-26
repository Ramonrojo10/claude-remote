#!/bin/bash
set -e

echo "[$(date)] Starting Claude Remote..."

# Clone or pull repo
if [ ! -d ~/karmabyte/.git ]; then
  git clone https://github.com/Ramonrojo10/karmabyte.git ~/karmabyte 2>/dev/null || true
else
  cd ~/karmabyte && git pull 2>/dev/null || true
fi

# tmux config
cat > ~/.tmux.conf << 'TC'
set -g mouse on
set -g history-limit 50000
set -g default-terminal "xterm-256color"
TC

# Start Claude in tmux
cd ~/karmabyte
tmux new-session -d -s claude "claude --dangerously-skip-permissions --continue" || true
echo "[$(date)] tmux+claude started"

echo "[$(date)] Starting ttyd on port 7682..."

# Start ttyd with auth
ttyd --port 7682 --writable \
  -c "${TTYD_USER:-karma}:${TTYD_PASS:-KarmaOps2026}" \
  -t fontSize=14 \
  -t 'theme={"background":"#0F0F0F","foreground":"#e0e0e0","cursor":"#7C3AED"}' \
  tmux attach-session -t claude &
TTYD_PID=$!
echo "[$(date)] ttyd PID: $TTYD_PID"

# Watchdog loop
while true; do
  sleep 30

  # Restart claude if tmux session died
  if ! tmux has-session -t claude 2>/dev/null; then
    echo "[$(date)] Claude died, restarting..."
    cd ~/karmabyte
    tmux new-session -d -s claude "claude --dangerously-skip-permissions --continue"
  fi

  # Restart ttyd if died
  if ! kill -0 $TTYD_PID 2>/dev/null; then
    echo "[$(date)] ttyd died, restarting..."
    ttyd --port 7682 --writable \
      -c "${TTYD_USER:-karma}:${TTYD_PASS:-KarmaOps2026}" \
      -t fontSize=14 \
      -t 'theme={"background":"#0F0F0F","foreground":"#e0e0e0","cursor":"#7C3AED"}' \
      tmux attach-session -t claude &
    TTYD_PID=$!
  fi
done
