FROM mambaorg/micromamba:1.3.1

USER root
COPY . .
RUN apt update && apt install -y cmake g++
RUN micromamba install -y -n base -f env.yaml \
    && micromamba clean --all --yes
ARG MAMBA_DOCKERFILE_ACTIVATE=1


USER $MAMBA_USER
<<<<<<< HEAD
# TODO this is not really needed for build; it is a test. Go somewhere else
#RUN python run_simulation.py --quiet --backend cpp_standalone models
=======
RUN python run_simulation.py -h
RUN python run_simulation.py --backend cpp_standalone models


>>>>>>> 62c3aab (Update Dockerfile)
#RUN apt install -y r-base
