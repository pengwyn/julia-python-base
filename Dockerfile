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


RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
RUN ln -fs /usr/share/zoneinfo/Asia/Singapore /etc/localtime


# Install python packages into virutalenv
ENV VIRTUAL_ENV=/usr/src/app/special-venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
ENV PYTHONUNBUFFERED=1

RUN pip3 install --upgrade pip
RUN pip3 install --no-cache-dir wheel
RUN pip3 install --no-cache-dir julia

# Install julia
RUN wget --no-verbose https://julialang-s3.julialang.org/bin/linux/x64/1.5/julia-1.5.0-linux-x86_64.tar.gz && \
    tar -xzf julia-1.5.0-linux-x86_64.tar.gz && \
    cp -r julia-1.5.0 /opt/

# configure julia
ENV PATH="/opt/julia-1.5.0/bin:$PATH"

RUN julia -e 'using Pkg; Pkg.add(["PyCall", "PackageCompiler"]); Pkg.precompile()'


    awscli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \ 
    && ./aws/install
