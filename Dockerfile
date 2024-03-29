FROM python:pyversion-slim-bullseye

ARG JULIA_VERSION

RUN [ -n "$JULIA_VERSION" ]

ENV APP_PATH=/usr/src/app
WORKDIR $APP_PATH

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    golang \
    ca-certificates \
    locales \
    fonts-liberation \
    build-essential \
    wget \
    cmake \
    bzip2 \
    curl \
    unzip \
    git \
    gfortran \
    perl \
    patchelf \
    cgroup-tools


RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
RUN ln -fs /usr/share/zoneinfo/Asia/Singapore /etc/localtime


# Install python packages into virutalenv
ENV VIRTUAL_ENV=/usr/src/app/special-venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$VIRTUAL_ENV/lib:/usr/local/lib"
ENV PYTHONUNBUFFERED=1

RUN pip3 install --upgrade pip
RUN pip3 install --no-cache-dir wheel twine
RUN pip3 install --no-cache-dir julia

RUN pip3 install --no-cache-dir notebook jupyterhub jupyterlab
RUN jupyter notebook --generate-config

# Build our own version of julia since the binaries make it impossible to get libraries right for extension modules.
# And also out of principle for sensible packaging good practice...
# Note: doing this all in one go to avoid saving unnecessary files into the image since the build can be quite big
# Note: JULIA_CPU_TARGET may not be required but it doesn't hurt so far
RUN wget https://github.com/JuliaLang/julia/releases/download/v${JULIA_VERSION}/julia-${JULIA_VERSION}.tar.gz \
    && tar -xvf julia-${JULIA_VERSION}.tar.gz \
    && cd julia-${JULIA_VERSION} \
    && make O=build configure \
    && cd build \
    && echo prefix=/usr/local >> Make.user \
    && make -j MARCH=x86-64 JULIA_CPU_TARGET="generic;sandybridge,-xsaveopt,clone_all;haswell,-rdrnd,base(1)" VERBOSE=1 \
    && make install \
    && cd ../.. \
    && rm -r julia-${JULIA_VERSION} julia-${JULIA_VERSION}.tar.gz

# jlpkg for easier package installs (without constant registry updates)
RUN julia -e 'using Pkg; pkg"add jlpkg"; using jlpkg; jlpkg.install(destdir="/usr/local/bin")'

RUN jlpkg add PyCall PackageCompiler Revise IJulia
RUN jlpkg precompile


RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \ 
    && ./aws/install
