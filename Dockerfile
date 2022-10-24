# docker buildx create --use
# docker buildx build --platform linux/amd64,linux/arm64 -t karoid/postgres-textsearch_ko:14-bullseye -t karoid/postgres-textsearch_ko:latest --push .

ARG OPENSEARCH_VERSION="2.3.0"
FROM opensearchproject/opensearch:$OPENSEARCH_VERSION
ARG OPENSEARCH_VERSION
# https://bitbucket.org/soosinha/seunjeon-opensearch/src/main/opensearch/
ARG SEUNJEON_VERSION="1.0.0.0"

# docker run --rm -it --user root opensearchproject/opensearch:2.3.0 bash

# build zip
RUN 

# install plugin to opensearch
RUN yum install wget zip -y \
  && cd /usr/share/opensearch \
  && bash <(curl -s https://bitbucket.org/soosinha/seunjeon-opensearch/raw/main/opensearch/scripts/downloader.sh) -e $OPENSEARCH_VERSION -p $SEUNJEON_VERSION \
  && ./bin/opensearch-plugin install file://`pwd`/opensearch-analysis-seunjeon-$SEUNJEON_VERSION.zip

# RUN git clone https://bitbucket.org/eunjeon/mecab-ko.git \
#   && cd mecab-ko \
#   && wget 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD' -O config.guess \
#   && wget 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD' -O config.sub \
#   && ./configure \
#   && make all \
#   && make install

# Cleaning
# RUN apt-get remove -y build-essential git wget autoconf
# RUN rm -rf mecab-*

# EXPOSE 5432
# CMD ["postgres"]
