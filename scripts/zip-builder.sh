#!/usr/bin/env bash
TMP_DIR="/tmp/build"

cd $TMP_DIR

git clone https://karoid@bitbucket.org/soosinha/seunjeon-opensearch.git --depth 1
cd seunjeon-opensearch
# 사전 다운로드
./scripts/download-dict.sh mecab-ko-dic-2.1.1-20180720

# 사전 빌드(mecab-ko-dic/* -> src/main/resources/*.dat)
#   src/main/resources/ 디렉토리에 컴파일된 사전들이 만들어집니다.
echo 'addSbtPlugin("com.jsuereth" % "sbt-pgp" % "1.1.0")' >> project/plugins.sbt
sed -i '/val opensearchVersion = "1.0.0"/c\val opensearchVersion = "1.3.6"' build.sbt
sed -i '/val opensearchJarVersion = "1.0.0-beta1"/c\val opensearchJarVersion = "1.3.6"' build.sbt
sbt -J-Xmx2G "runMain org.bitbucket.eunjeon.seunjeon.DictBuilder"

