FROM mambaorg/micromamba:1.3.1
<<<<<<< HEAD
USER root
RUN /usr/bin/apt update
RUN /usr/bin/apt install -y cmake gcc # make
COPY --chown=$MAMBA_USER:$MAMBA_USER env.yaml /tmp/env.yaml
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba clean --all --yes
ARG MAMBA_DOCKERFILE_ACTIVATE=1
RUN python -c 'import uuid; print(uuid.uuid4())' > /tmp/my_uuid
RUN python -c "import brian2"
COPY . .
USER $MAMBA_USER
RUN python run_simulation.py -h
RUN python run_simulation.py --quiet --backend cpp_standalone models


=======

USER root
COPY . .
RUN apt update && apt install -y cmake g++ r-base
RUN micromamba install -y -n base -f env.yaml \
    && micromamba clean --all --yes
ARG MAMBA_DOCKERFILE_ACTIVATE=1


USER $MAMBA_USER
# TODO this is not really needed for build; it is a test. Go somewhere else
#RUN python run_simulation.py --quiet --backend cpp_standalone models
>>>>>>> 3a3103816442b7d8eb0f4fafb81572d31d1498ea
#RUN apt install -y r-base
