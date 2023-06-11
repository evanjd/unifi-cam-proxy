ARG version=3.9
ARG tag=${version}-slim-buster

FROM python:${tag} as builder
WORKDIR /app
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

# RUN ECHO 'deb http://ftp.debian.org/debian experimental main contrib non-free' >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y \
    cargo \
    git \
    gcc \
    g++ \
    libjpeg-dev \
    libc-dev \
    linux-headers-amd64 \
    musl-dev \
    patchelf \
    rustc \
    zlib1g-dev

RUN pip install -U pip wheel setuptools maturin
COPY requirements.txt .
RUN pip install -r requirements.txt --no-build-isolation


FROM python:${version}-slim-buster
WORKDIR /app

ARG version

COPY --from=builder \
    /usr/local/lib/python${version}/site-packages \
    /usr/local/lib/python${version}/site-packages

RUN apt-get update
RUN apt-get install ffmpeg netcat-openbsd libusb-dev musl-dev -y
RUN ln -s /usr/lib/x86_64-linux-musl/libc.so /lib/libc.musl-x86_64.so.1

COPY . .
RUN pip install . --no-cache-dir

COPY ./docker/entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["unifi-cam-proxy"]
