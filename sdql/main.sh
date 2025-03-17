#!/bin/bash

echo Running SDQL:
(cd baseline; ./bench.sh; ./mttkrp.sh)
(cd slotted; ./bench.sh; ./mttkrp.sh)
