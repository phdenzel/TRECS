# syntax=docker/dockerfile:1.4
# Dockerfile for TRECS
FROM alpine/git:2.36.3 as downloader

# Tarball utility script
RUN apk add --no-cache aria2 libarchive-tools
RUN <<EOF
    cat <<'EOE' > /tarball.sh
mkdir -p packages/"$1" && cd packages && aria2c -x 5 --out "${2##*/}" "$2" && tar zxf "${2##*/}" -C "$1" --strip-components=1 && rm -rf *.tar.gz
EOE
EOF

# download tarballs
RUN . /tarball.sh gsl https://ftp.gnu.org/gnu/gsl/gsl-2.7.tar.gz \
    && rm -rf doc
RUN . /tarball.sh lapack https://github.com/Reference-LAPACK/lapack/archive/refs/tags/v3.11.0.tar.gz \
    && rm -rf DOCS
RUN . /tarball.sh cfitsio https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio-4.2.0.tar.gz \
    && rm -rf docs
RUN . /tarball.sh healpix https://sourceforge.net/projects/healpix/files/Healpix_3.82/Healpix_3.82_2022Jul28.tar.gz \
    && rm -rf doc

# Clone utility script
RUN <<EOF
    cat <<'EOE' > /clone.sh
mkdir -p repositories/"$1" && cd repositories/"$1" && git init && git remote add origin "$2" && git fetch origin "$3" --depth=1 && git reset --hard "$3" && rm -rf .git
EOE
EOF

# clone main project repo
# RUN . /clone.sh TRECS https://github.com/abonaldi/TRECS.git master \
#     && rm -rf README.md INSTALL.md .gitattributes .gitignore
RUN . /clone.sh TRECS https://github.com/phdenzel/TRECS.git ce002e101d73327ff3dd0e83ab1d8ee00b82fe57 \
    && rm -rf README.md INSTALL.md .gitattributes .gitignore


# Build dependencies
FROM python:3.10.9-bullseye as builder

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \ 
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y \
    build-essential cmake gfortran libcurl4-openssl-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=downloader /git/packages /git/repositories /

RUN cd /gsl && ./configure --prefix=/usr/local/ && make && make install
RUN mkdir -p /lapack/build && cd /lapack/build \
    && cmake -DCMAKE_INSTALL_LIBDIR=/usr/local/lib -DBUILD_SHARED_LIBS=ON .. \
    && cmake --build . -j --target install
RUN cd /cfitsio && ./configure --prefix=/usr/local && make && make install
RUN mv /healpix /opt/ && cd /opt/healpix && ./configure --auto=all && make
RUN cd /TRECS && cp .make/docker.make.inc make.inc && make all


# Final stage
FROM python:3.10.9-bullseye as runtime
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/local/include /usr/local/include
COPY --from=builder /usr/lib/x86_64-linux-gnu/libgfortran* /usr/lib/x86_64-linux-gnu
COPY --from=builder /opt/healpix /opt/healpix
RUN ldconfig /usr/local/lib

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install numpy scipy matplotlib scikit-learn astropy

ARG USER_NAME
ARG USER_UID
ARG USER_GID
RUN groupadd --gid $USER_GID $USER_NAME && useradd -m --uid $USER_UID --gid $USER_GID $USER_NAME

USER $USER_NAME
ENV HOME=/home/$USER_NAME
WORKDIR /home/$USER_NAME
COPY --from=builder --chown=$USER_NAME /TRECS TRECS
ENV PATH="${HOME}/TRECS/bin:${PATH}"

ENTRYPOINT ["/bin/bash"]
