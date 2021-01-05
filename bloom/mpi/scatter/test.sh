#!/bin/sh
tmux new-session -s MySession -n Shell1 -d 'printf "you are in tmux\npress <ctrl>-c in each pane to exit\n"; ruby scatter-client.rb 127.0.0.1:12345 0 3 3'
tmux split-window -t MySession:0 'ruby scatter-client.rb 127.0.0.1:12347 1 3 1'
tmux split-window -t MySession:0 'ruby scatter-client.rb 127.0.0.1:12348 1 3 2'
tmux split-window -t MySession:0 'ruby scatter-client.rb 127.0.0.1:12346 1 3 0'
tmux select-layout -t MySession:0 tiled

tmux attach -tMySession
