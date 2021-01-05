#!/bin/sh
tmux new-session -s MySession -n Shell1 -d 'printf "you are in tmux\npress <ctrl>-c in each pane to exit\n"; ruby promise_server.rb 127.0.0.1:12345'
tmux split-window -t MySession:0 'ruby promise_client.rb 127.0.0.1:12345'
tmux select-layout -t MySession:0 tiled

tmux attach -tMySession
