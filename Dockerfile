## For release new version
# docker buildx create --use
# docker buildx build --platform linux/amd64,linux/arm64 -t karoid/opensearch-seunjeon:2.3.0.0 -t karoid/opensearch-seunjeon:latest --push .

## For debugging command lines
# docker run --rm -it --user root opensearchproject/opensearch:2.3.0 bash

ARG OPENSEARCH_VERSION="2.3.0"
FROM opensearchproject/opensearch:$OPENSEARCH_VERSION
ARG OPENSEARCH_VERSION
ARG SEUNJEON_VERSION="2.3.0.0"

RUN mkdir -p /tmp/build && cd /tmp/build

COPY ./scripts/downloader.sh /tmp/build
USER root

# install plugin to opensearch
RUN yum install wget zip -y \
  && cd /tmp/build \
  && chmod 700 downloader.sh \
  && ./downloader.sh -e $OPENSEARCH_VERSION -p $SEUNJEON_VERSION \
  && $(dirname $(which opensearch))/opensearch-plugin install file://`pwd`/opensearch-analysis-seunjeon-2.3.0.0.zip \
  && rm -r /tmp/build \
  && yum remove wget zip -y
USER opensearch

EXPOSE 9200 9300 9600 9650

# Label
LABEL org.label-schema.schema-version="1.0" \
  org.label-schema.name="opensearch" \
  org.label-schema.version="$OS_VERSION" \
  org.label-schema.url="https://opensearch.org" \
  org.label-schema.vcs-url="https://github.com/OpenSearch" \
  org.label-schema.license="Apache-2.0" \
  org.label-schema.vendor="OpenSearch"

# CMD to run
 ENTRYPOINT ["./opensearch-docker-entrypoint.sh"]
 CMD ["opensearch"]