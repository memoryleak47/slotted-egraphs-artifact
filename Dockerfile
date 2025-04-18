# Copyright (c) 2021-2023 Kyle Roarty, Andres Goens
# All Rights Reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met: redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer;
# redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution;
# neither the name of the copyright holders nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
FROM rust:1.82
ENV DEBIAN_FRONTEND=noninteractive
RUN apt -y update
RUN apt -y upgrade

#Get dependencies for models
RUN apt-get update && apt-get install -y \
    git \
    curl \
    sudo \
    time \
    bc \
    coreutils

# Create a regular user
RUN useradd --user-group --system --create-home --no-log-init user
USER user
WORKDIR /home/user

# Install the uv package manager
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Elan
RUN curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf > elan-install.sh
RUN chmod +x elan-install.sh
RUN ./elan-install.sh -y
RUN rm elan-install.sh
RUN echo ". /home/user/.elan/env" >> /home/user/.bashrc
RUN /home/user/.elan/bin/elan self update
RUN /home/user/.elan/bin/elan toolchain install v4.14.0-rc1

COPY --chown=user . .

#Build Lean-Egg
WORKDIR /home/user/lean-egg
RUN /home/user/.elan/bin/lake update
RUN /home/user/.elan/bin/lake build
RUN cd /home/user/lean-egg/Lean/Egg/Tests/mathlib4/mathlib4; /home/user/.elan/bin/lake update

# Download and install Python packages
WORKDIR /home/user/
RUN /home/user/.local/bin/uv sync

# Download dependencies and build rust projects
RUN cd /home/user/functional-array-language/egg-rise; cargo build --release
RUN cd /home/user/functional-array-language/slotted-rise; cargo build --release
RUN cd /home/user/sdql/baseline; cargo build --release
RUN cd /home/user/sdql/slotted; cargo build --release


CMD ["/usr/bin/bash"]
