FROM mambaorg/micromamba:1.3.1
USER root
RUN /usr/bin/apt update
RUN /usr/bin/apt install -y cmake gcc curl
COPY --chown=$MAMBA_USER:$MAMBA_USER env.yaml /tmp/env.yaml
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba clean --all --yes
ARG MAMBA_DOCKERFILE_ACTIVATE=1
RUN python -c "import brian2"
COPY . .
USER $MAMBA_USER
RUN python run_simulation.py -h
RUN curl -fsSL https://install.julialang.org | sh -s -- -y
RUN python run_simulation.py --quiet --backend cpp_standalone models
RUN ls 
RUN /bin/bash "/home/mambauser/.bashrc"
RUN /bin/bash "/home/mambauser/.profile"
RUN /home/mambauser/.juliaup/bin/julia -e 'using Pkg;Pkg.add("UnicodePlots")'
RUN /home/mambauser/.juliaup/bin/julia -e 'using Pkg;Pkg.add("UMAP")'
RUN /home/mambauser/.juliaup/bin/julia -e 'using Pkg;Pkg.add("Conda")'
RUN /home/mambauser/.juliaup/bin/julia -e 'using Pkg;Pkg.add("PyCall")'
WORKDIR julia_read_dir
RUN ls spikes_for_julia_read.p & echo "hack to print,assert"
RUN /home/mambauser/.juliaup/bin/julia UMAP_of_spikes.jl

RUN python -m unittest tests/test_orca.py