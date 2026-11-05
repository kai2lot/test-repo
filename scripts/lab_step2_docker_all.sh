#!/bin/bash
set -e

WORKDIR="/mnt/c/Users/kai2lot7472/Desktop/worksm"
cd "$WORKDIR"

echo "=== 4. Docker 기본 점검 및 hello-world / ubuntu 컨테이너 실습 ==="
echo "$ docker --version"
docker --version
echo "$ docker info | head -n 25"
docker info | head -n 25

echo ""
echo "[4-1. hello-world 컨테이너 실행]"
echo "$ docker run --rm hello-world"
docker run --rm hello-world

echo ""
echo "[4-2. ubuntu 컨테이너 백그라운드 실행 및 내부 명령(exec) 수행]"
docker rm -f ubuntu-lab 2>/dev/null || true
echo "$ docker run -d --name ubuntu-lab ubuntu:24.04 sleep infinity"
docker run -d --name ubuntu-lab ubuntu:24.04 sleep infinity
echo "$ docker ps"
docker ps
echo '$ docker exec ubuntu-lab bash -c "echo Hello from Ubuntu Container! > /tmp/test.txt && ls -la /tmp/test.txt && cat /tmp/test.txt"'
docker exec ubuntu-lab bash -c "echo Hello from Ubuntu Container! > /tmp/test.txt && ls -la /tmp/test.txt && cat /tmp/test.txt"

echo ""
echo "=== 5. 커스텀 Dockerfile 이미지 빌드 및 포트 매핑 (8080, 8081) 실습 ==="
echo "$ docker build -t my-web:1.0 ."
docker build -t my-web:1.0 .
echo "$ docker images"
docker images

docker rm -f my-web-8080 my-web-8081 2>/dev/null || true
echo "$ docker run -d -p 8080:80 --name my-web-8080 my-web:1.0"
docker run -d -p 8080:80 --name my-web-8080 my-web:1.0
echo "$ docker run -d -p 8081:80 --name my-web-8081 my-web:1.0"
docker run -d -p 8081:80 --name my-web-8081 my-web:1.0

sleep 2
echo "$ docker ps -a"
docker ps -a
echo "$ curl -i http://localhost:8080/health"
curl -i http://localhost:8080/health
echo "$ curl -s http://localhost:8080 | grep -E '<h1>|<div>'"
curl -s http://localhost:8080 | grep -E '<h1>|<div>'
echo "$ curl -s http://localhost:8081 | grep -E '<h1>|<div>'"
curl -s http://localhost:8081 | grep -E '<h1>|<div>'

echo ""
echo "[Docker 운영 명령: logs, stats, stop]"
echo "$ docker logs --tail 5 my-web-8080"
docker logs --tail 5 my-web-8080
echo "$ docker stats --no-stream"
docker stats --no-stream

echo ""
echo "=== 6. 바인드 마운트(Bind Mount) 실시간 변경 반영 검증 ==="
mkdir -p ~/codyssey/bind_mount_site
echo "<h1>Version 1: Before Host File Edit</h1>" > ~/codyssey/bind_mount_site/index.html
docker rm -f bind-web 2>/dev/null || true
echo "$ docker run -d -p 8083:80 --name bind-web -v ~/codyssey/bind_mount_site:/usr/share/nginx/html:ro my-web:1.0"
docker run -d -p 8083:80 --name bind-web -v ~/codyssey/bind_mount_site:/usr/share/nginx/html:ro my-web:1.0
sleep 1
echo "[변경 전 curl 응답 확인]"
echo "$ curl http://localhost:8083"
curl http://localhost:8083
echo "[호스트에서 파일 수정 후 컨테이너 재빌드/재시작 없이 즉시 반영 확인]"
echo '$ echo "<h1>Version 2: Updated on Host Immediately! (Bind Mount Verified)</h1>" > ~/codyssey/bind_mount_site/index.html'
echo "<h1>Version 2: Updated on Host Immediately! (Bind Mount Verified)</h1>" > ~/codyssey/bind_mount_site/index.html
echo "$ curl http://localhost:8083"
curl http://localhost:8083

echo ""
echo "=== 7. Docker 볼륨(Volume) 데이터 영속성 검증 ==="
docker rm -f vol-test vol-test2 2>/dev/null || true
docker volume rm mydata 2>/dev/null || true
echo "$ docker volume create mydata"
docker volume create mydata
echo "$ docker volume ls"
docker volume ls
echo "$ docker run -d --name vol-test -v mydata:/data ubuntu:24.04 sleep infinity"
docker run -d --name vol-test -v mydata:/data ubuntu:24.04 sleep infinity
echo '$ docker exec vol-test bash -lc "echo \"Persistent Data in Docker Volume (2026-11-05)\" > /data/hello.txt && cat /data/hello.txt"'
docker exec vol-test bash -lc "echo \"Persistent Data in Docker Volume (2026-11-05)\" > /data/hello.txt && cat /data/hello.txt"
echo "[첫 번째 컨테이너(vol-test) 강제 삭제]"
echo "$ docker rm -f vol-test"
docker rm -f vol-test
echo "[새로운 컨테이너(vol-test2)에 동일 볼륨(mydata) 마운트 후 데이터 유지 확인]"
echo "$ docker run -d --name vol-test2 -v mydata:/data ubuntu:24.04 sleep infinity"
docker run -d --name vol-test2 -v mydata:/data ubuntu:24.04 sleep infinity
echo '$ docker exec vol-test2 bash -lc "ls -la /data && cat /data/hello.txt"'
docker exec vol-test2 bash -lc "ls -la /data && cat /data/hello.txt"
docker rm -f vol-test2

echo ""
echo "=== 8. 보너스 과제: Docker Compose 멀티 컨테이너 + 환경변수 + 네트워크 검증 ==="
docker compose down 2>/dev/null || true
echo "$ docker compose up -d"
docker compose up -d
sleep 2
echo "$ docker compose ps"
docker compose ps
echo "[웹 서버 -> Redis 컨테이너 서비스 디스커버리(DNS) 및 네트워크 통신 확인]"
echo '$ docker exec compose-web sh -c "env | grep -E \"APP_ENV|TZ|BACKEND_REDIS_HOST\" && ping -c 2 cache-redis"'
docker exec compose-web sh -c "env | grep -E \"APP_ENV|TZ|BACKEND_REDIS_HOST\" && ping -c 2 cache-redis"
echo "$ curl -I http://localhost:8082"
curl -I http://localhost:8082
echo "$ docker compose logs --tail 5"
docker compose logs --tail 5

