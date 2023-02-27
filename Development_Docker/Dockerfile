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
#ENV sim_name=$(date +"$folder_name/%d-%m_%Hh%Mm%Ss")
#RUN sim_name=$(date +"$folder_name/%d-%m_%Hh%Mm%Ss")
WORKDIR spikes_path
WORKDIR $HOME
RUN python run_simulation.py --save_path spikes_path --code_path --backend cpp_standalone --quiet LSM --precision fp8 --size 4992 --trial 1
RUN curl -fsSL https://install.julialang.org | sh -s -- -y
ENV PATH="$PATH:/home/mambauser/.juliaup/bin/"
RUN julia -e 'import Pkg;Pkg.add("UpdateJulia")'
RUN julia -e 'using UpdateJulia;update_julia()'
RUN julia setup.jl
WORKDIR spikes_path
RUN /home/mambauser/.juliaup/bin/julia UMAP_of_spikes.jl

#RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.8/julia-1.8.3-linux-x86_64.tar.gz
#RUN tar zxvf julia-1.8.3-linux-x86_64.tar.gz
#ENV PATH="$PATH:julia-1.8.3/bin"

#RUN julia -e 'import Pkg;Pkg.add("UpdateJulia")'
#RUN julia -e 'using UpdateJulia;update_julia()'


#RUN python -m unittest tests/test_orca.py
