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
RUN python run_simulation.py --quiet --backend cpp_standalone models
ENV sim_name=$(date +"$folder_name/%d-%m_%Hh%Mm%Ss")
RUN sim_name=$(date +"$folder_name/%d-%m_%Hh%Mm%Ss")
RUN python run_simulation.py --save_path $sim_name --code_path --backend cpp_standalone --quiet LSM --precision fp8 --size 4992 --trial 1
#RUN python -m unittest tests/test_orca.py
RUN curl -fsSL https://install.julialang.org | sh -s -- -y
RUN /home/mambauser/.juliaup/bin/julia setup.jl
WORKDIR $sim_name
RUN /home/mambauser/.juliaup/bin/julia UMAP_of_spikes.jl
