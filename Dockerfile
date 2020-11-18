FROM python:3.8-slim

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
    git


RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
RUN ln -fs /usr/share/zoneinfo/Asia/Singapore /etc/localtime


# Install python packages into virutalenv
ENV VIRTUAL_ENV=/usr/src/app/special-venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$VIRTUAL_ENV/lib"
ENV PYTHONUNBUFFERED=1

RUN pip3 install --upgrade pip
RUN pip3 install --no-cache-dir wheel
RUN pip3 install --no-cache-dir julia

# Install julia
# RUN wget --no-verbose https://julialang-s3.julialang.org/bin/linux/x64/1.5/julia-1.5.0-linux-x86_64.tar.gz \
#     && tar -xzf julia-1.5.0-linux-x86_64.tar.gz \
#     && rm julia-1.5.0/lib/julia/libstdc++.so.6 \
#     && cp -r julia-1.5.0 /opt/

# # configure julia
# ENV PATH="/opt/julia-1.5.0/bin:$PATH"

# Build our own version of julia since the binaries make it impossible to get libraries right for extension modules.
# And also out of principle for sensible packaging good practice...
RUN wget https://github.com/JuliaLang/julia/releases/download/v1.5.3/julia-1.5.3.tar.gz \
    && tar -xvf julia-1.5.3.tar.gz

RUN apt-get install -y --no-install-recommends \
    gfortran \
    perl

RUN cd julia-1.5.3 \
    && make O=build configure \
    && cd build \
    && echo prefix=/usr/local >> Make.user \
    && make -j 6 \
    && make install

RUN julia -e 'using Pkg; Pkg.add(["PyCall", "PackageCompiler"]); Pkg.precompile()'


RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \ 
    && ./aws/install

# # Get the latest version of cmake
# RUN wget --no-verbose https://github.com/Kitware/CMake/releases/download/v3.19.0-rc3/cmake-3.19.0-rc3.tar.gz \
#     && tar -xvf cmake-3.19.0-rc3.tar.gz \
#     && cd cmake-3.19.0-rc3 \
#     && cmake -DCMAKE_USE_OPENSSL=OFF -DCMAKE_BUILD_TYPE=Release . \
#     && make -j \
#     && make install
