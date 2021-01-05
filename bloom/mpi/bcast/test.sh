#!/bin/sh
tmux new-session -s MySession -n Shell1 -d 'printf "you are in tmux\npress <ctrl>-c in each pane to exit\n"; ruby bcast-client.rb 127.0.0.1:12345 1 3 3'
tmux split-window -t MySession:0 'ruby bcast-client.rb 127.0.0.1:12347 0 3 1'
tmux split-window -t MySession:0 'ruby bcast-client.rb 127.0.0.1:12348 0 3 2'
tmux split-window -t MySession:0 'ruby bcast-client.rb 127.0.0.1:12346 0 3 0'
tmux select-layout -t MySession:0 tiled

tmux attach -tMySession
