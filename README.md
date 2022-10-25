# opensearch-seunjeon
opensearch로 한국어 검색 환경을 구축할 수 있는 eunjeon Plugin 설치  
opensearch에 eunjeon plugin이 설치된 Docker image builder

# Usage
## Making plugin
```bash
# download plugin
bash <(curl -s https://raw.githubusercontent.com/Karoid/opensearch-seunjeon/main/scripts/downloader.sh) -e <opensearch-version> -p <plugin-version>
  에제) $ bash <(curl -s https://raw.githubusercontent.com/Karoid/opensearch-seunjeon/main/scripts/downloader.sh) -e 2.3.0 -p 2.3.0.0

# install plugin
$(dirname $(which opensearch))/opensearch-plugin install file://`pwd`/opensearch-analysis-seunjeon-<plugin-version>.zip
  예제) $ $(dirname $(which opensearch))/opensearch-plugin install file://`pwd`/opensearch-analysis-seunjeon-2.3.0.0.zip
```
* downloader.sh 가 하는 일은 opensearch-analysis-seunjeon-<plugin-version>.zip 파일을 내려받은 후 plugin-descriptor.properties 의 opensearch.version 을 변경하여 재압축합니다.
* opensearch가 버전 업 될때마다 플러그인을 재배포하는데 어려움이 있어 스크립트를 제공합니다.
### Usable Plugin Release
| opensearch-analysis-seunjeon | target opensearch | release note |
| ------------------------------- | ---------------------| ------------ |
| 2.3.0.0                         | 2.3.0                |  |

## docker 단독 사용
docker hub에서 받아서 사용하는 경우
```bash
docker run -d -p 9200:9200 --rm -v opensearch:/usr/share/opensearch/data -e "discovery.type=single-node" karoid/opensearch-seunjeon:2.3.0.0
```
프로젝트로 빌드해서 사용하는 경우
```bash
docker build . --tag opensearch-seunjeon
docker run -d -p 9200:9200 --rm -v opensearch:/usr/share/opensearch/data -e "discovery.type=single-node" opensearch-seunjeon
```
## docker-compose.yml으로 사용
```yml
version: "3.9"

services:
  elasticsearch:
    image: karoid/opensearch-seunjeon:2.3.0.0
    environment:
      - discovery.type=single-node
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
     - opensearch:/usr/share/opensearch/data
    ports:
      - 9200:9200
```

### [Usable Docker Image Release](https://hub.docker.com/r/karoid/opensearch-seunjeon)
| opensearch-analysis-seunjeon | target opensearch | release note |
| ------------------------------- | ---------------------| ------------ |
| 1.3.6.0                         | 1.3.6               | Compatible with opensearch 7.10 |
| 2.3.0.0                         | 2.3.0                |  |

# Testing
도커의 경우 opensearch 컨테이너에 들어간다.
```bash
curl -XPUT --insecure -u admin:admin 'https://localhost:9200/test/'  -H 'Content-Type: application/json' -d '{
  "settings" : {
    "index":{
      "analysis":{
        "analyzer":{
          "korean":{
            "type":"custom",
            "tokenizer":"seunjeon_default_tokenizer"
          }
        },
        "tokenizer": {
          "seunjeon_default_tokenizer": {
            "type": "seunjeon_tokenizer",
            "index_eojeol": false
          }
        }
      }
    }
  },
  "mappings": {
    "text" : {
      "properties" : {
        "text" : {
          "type" : "string",
          "analyzer": "korean"
        }
      }
    }
  }
}'

curl -XGET --insecure -u admin:admin 'https://localhost:9200/test/_analyze?pretty=true'  -H 'Content-Type: application/json' -d '{"analyzer": "korean","text": "아버지가 방에 들어간다"}'
```
이렇게 입력했을 때 다음 응답이 나오면 제대로 설치가 된 것이다
```json
{
  "tokens" : [
    {
      "token" : "아버지/N",
      "start_offset" : 0,
      "end_offset" : 3,
      "type" : "N",
      "position" : 0
    },
    {
      "token" : "방/N",
      "start_offset" : 5,
      "end_offset" : 6,
      "type" : "N",
      "position" : 1
    },
    {
      "token" : "들어가/V",
      "start_offset" : 8,
      "end_offset" : 11,
      "type" : "V",
      "position" : 2
    }
  ]
}
```

# Building new version of plugin zip file
만약 opensearch 버전이 올라가고 [opensearch-seunjeon](https://bitbucket.org/soosinha/seunjeon-opensearch/src/main/opensearch/) 프로젝트에 최신 버전의 플러그인 코드가 공개된다면 다음 명령으로 플러그인을 다시 빌드할 수 있습니다.
```bash
mkdir -p build
docker run -it --name plugin-builder -v $(pwd)/build:/tmp/build -v $(pwd)/scripts:/tmp/scripts mozilla/sbt:8u292_1.5.7 bash
# container bash 진입 > dictionary 생성
chmod 700 /tmp/scripts/*
/tmp/scripts/zip-builder.sh
# zip 생성
cd /tmp/build/seunjeon-opensearch && sbt
sbt:opensearch-analysis-seunjeon> project opensearch
sbt:opensearch-analysis-seunjeon> opensearchZip
```
다음 명령이 성공하면 `build/opensearch-analysis-seunjeon/seunjeon-opensearch/opensearch/target/opensearch-analysis-seunjeon-assembly-2.3.0.jar`에 파일이 만들어진다

만약 opensearchZip을 빌드할 때 사용하는 opensearch의 버전을 올리고 싶으면 `zip-builder.sh`의 다음 두 부분의 2.3.0을 변경하면 된다
```sbt
sed -i '/val opensearchVersion = "1.0.0"/c\val opensearchVersion = "2.3.0"' build.sbt
sed -i '/val opensearchJarVersion = "1.0.0-beta1"/c\val opensearchJarVersion = "2.3.0"' build.sbt
```

# Original Projects
[seunjeon](https://bitbucket.org/eunjeon/seunjeon/src/master/elasticsearch/): 한국어 형태소분석기를 elasticsearch에 사용할 수 있도록 만든 plugin입니다.  
[opensearch-seunjeon](https://bitbucket.org/soosinha/seunjeon-opensearch/src/main/opensearch/): 기존의 elasticsearch에서 사용 가능하던 한국어 형태소 분석기를 opensearch에서 사용할 수 있도록 변경한 plugin입니다.