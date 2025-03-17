#!/bin/bash

sudo docker build -t slotted-image .
sudo docker run -w /home/user/artifact/functional-array-language slotted-image ./main.sh
sudo docker run -w /home/user/artifact/lean-egg slotted-image ./main.sh
sudo docker run -w /home/user/artifact/sdql slotted-image ./main.sh
