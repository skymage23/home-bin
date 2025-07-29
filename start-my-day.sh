#!/bin/bash

JUPYTER_PORT=8888
R_STUDIO_PORT=8787

body() (
   sleep 3
   firefox "http://127.0.0.1:$JUPYTER_PORT/notebooks/Documents/jupyter_notebooks/machine_learning/image_classification_playground.ipynb"&
   chrome_bg_pid=$!
   firefox "http://127.0.0.1:$R_STUDIO_PORT"
   trap "kill -9 $chrome_bg_pid" EXIT
   while true; do
       sleep 1;
   done
)

kill_jupyter_notebook(){
    ssh devtower1 "ps aux | grep -i 'jupyter' | awk -c '{ print \$2 }' | xargs kill -15"
}

body&
body_pid=$!
trap kill_jupyter_notebook EXIT

ssh \
-L $JUPYTER_PORT:localhost:$JUPYTER_PORT \
-L $R_STUDIO_PORT:localhost:$R_STUDIO_PORT \
devtower1 \
/home/cnugent/launch-jupyter-notebook.sh
