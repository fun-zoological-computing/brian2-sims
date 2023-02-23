FROM mambaorg/micromamba:1.3.1
USER root
RUN /usr/bin/apt update
RUN /usr/bin/apt install -y cmake gcc curl
COPY --chown=$MAMBA_USER:$MAMBA_USER env.yaml /tmp/env.yaml
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba clean --all --yes
ARG MAMBA_DOCKERFILE_ACTIVATE=1
RUN python -c 'import uuid; print(uuid.uuid4())' > /tmp/my_uuid
RUN python -c "import brian2"
COPY . .
USER $MAMBA_USER
RUN python run_simulation.py -h
Run curl -fsSL https://install.julialang.org | sh -s -y
RUN julia -c "using Pkg;"
RUN python run_simulation.py --quiet --backend cpp_standalone models
WORKDIR julia_read_dir
RUN cat *
RUN ls & echo "HacktoShowLSresults"
