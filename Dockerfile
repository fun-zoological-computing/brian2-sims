FROM mambaorg/micromamba:1.3.1
#RUN echo $(uname -a) && echo sdfljsdfljksdfljk
#RUN echo $(which apt) && echo sdfljsddddfljksdfljk
RUN /usr/bin/apt install -y cmake
COPY --chown=$MAMBA_USER:$MAMBA_USER env.yaml /tmp/env.yaml
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba clean --all --yes
ARG MAMBA_DOCKERFILE_ACTIVATE=1
RUN python -c 'import uuid; print(uuid.uuid4())' > /tmp/my_uuid
RUN python -c "import brian2"
COPY . .
USER $MAMBA_USER
RUN python run_simulation.py -h
#RUN apk update
#RUN apk install r-base
