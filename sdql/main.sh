#!/bin/bash

echo Running SDQL:
(cd baseline; ./bench.sh)
(cd slotted; ./bench.sh)
