#!/bin/bash

# This file can be removed, it's just a helper for me.

sudo docker build -t slotted-image .
sudo docker save slotted-image -o slotted-image.tar
