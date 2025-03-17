#!/bin/bash

sudo docker build -t my-image .
sudo docker run -w /home/user/artifact/functional-array-language my-image ./main.sh
sudo docker run -w /home/user/artifact/lean-egg my-image ./main.sh
sudo docker run -w /home/user/artifact/sdql my-image ./main.sh
