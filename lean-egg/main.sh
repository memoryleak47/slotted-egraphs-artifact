#!/bin/bash

echo "Running lean-egg"

. /home/user/.elan/env

lake update
lake build
