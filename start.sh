#!/bin/bash

# Define the session name
SESSION="trading"

# Start tmux session in the background if it doesn't already exist
tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
  echo "Starting new persistent tmux session: $SESSION"
  # Create the session and run the tradingagents CLI
  # We use 'bash -c' to ensure the environment is loaded and to keep the session alive if needed
  tmux new-session -d -s $SESSION "tradingagents"
else
  echo "Attaching to existing session: $SESSION"
fi

# Run ttyd and attach it to the tmux session
# -W allows writing/interacting
# tmux attach -t $SESSION connects the web terminal to the background process
ttyd -p 5050 -W tmux attach -t $SESSION
