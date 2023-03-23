# Dockerfile for TRECS
FROM alpine/git:2.36.3 as downloader

# Clone utility script
RUN <<EOF
    cat <<'EOE' > /clone.sh
mkdir -p repositories/"$1" && cd repositories/"$1" && git init && git remote add origin "$2" && git fetch origin "$3" --depth=1 && git reset --hard "$3" && rm -rf .git
EOE
EOF

# Configure git for ssh
#   - all private repos have to be cloned using `--mount=type=ssh` which passes
#     the host's ssh-agent to the image;
#   - use `--ssh default` for image build (default=$SSH_AUTH_SOCK)
RUN mkdir -p -m 0600 /root/.ssh/ && ssh-keyscan github.com >> /root/.ssh/known_hosts
RUN echo -e "[url \"git@github.com:\"]\n\tinsteadOf = https://github.com/" >> /root/.gitconfig
RUN echo "StrictHostKeyChecking no " > /root/.ssh/config

# clone project repo
RUN --mount=type=ssh . /clone.sh TRECS git@github.com:phdenzel/TRECS.git 3275a7b0ad611d185dd52437ac29f5daabc68aa3 \
    && rm -rf doc


# Tarball utility script
RUN apk add --no-cache aria2
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

COPY --from=downloader /git/packages/ /opt/

RUN cd /opt/gsl && ./configure && make && make install
RUN mkdir -p /opt/lapack/build && cd /opt/lapack/build \
    && cmake -DCMAKE_INSTALL_LIBDIR=/usr/local/lib .. \
    && cmake --build . -j --target install
RUN cd /opt/cfitsio && ./configure --prefix=/usr/local && make && make install
RUN cd /opt/healpix && ./configure --auto=all && make && make test


COPY --from=downloader /git/repositories/TRECS /TRECS
# RUN cd /TRECS && make all


# Final stage
FROM python:3.10.9-bullseye
COPY --from=builder /TRECS /TRECS
COPY --from=builder /usr/local/lib/ /usr/local/lib/
COPY --from=builder /usr/local/include/ /usr/local/include/
COPY --from=builder /opt/healpix/ /opt/healpix/
# COPY . /  # make sure dockerignore is correct

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install numpy scipy matplotlib astropy

ENTRYPOINT ["/bin/bash"]
# ENTRYPOINT ["/ska/docker/entrypoint.sh"]
