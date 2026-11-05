#!/bin/bash

echo "=== 9. 포트 충돌(Port Conflict) 진단 (lsof / ss / netstat) 및 해제 절차 검증 ==="
service docker start 2>/dev/null || true

# 1. 기존 8080 포트 점유 컨테이너 확인 및 실행 보장
docker rm -f conflict-test my-web-8080-restarted 2>/dev/null || true
docker start my-web-8080 2>/dev/null || docker run -d --restart unless-stopped -p 8080:80 --name my-web-8080 my-web:1.0

echo ""
echo "[Step 1] 이미 사용 중인 8080 포트에 두 번째 컨테이너(conflict-test) 실행 시도 -> 포트 충돌 에러 발생"
echo "$ docker run -d -p 8080:80 --name conflict-test my-web:1.0"
docker run -d -p 8080:80 --name conflict-test my-web:1.0 2>&1 || true

echo ""
echo "[Step 2] 포트 충돌 원인 진단 1: lsof 명령어로 8080 포트 점유 프로세스(PID) 확인"
echo "$ sudo lsof -i :8080"
lsof -i :8080

echo ""
echo "[Step 3] 포트 충돌 원인 진단 2: ss 명령어로 LISTEN 상태 소켓 및 PID 확인"
echo "$ sudo ss -tulpn | grep :8080"
ss -tulpn | grep :8080

echo ""
echo "[Step 4] 포트 충돌 원인 진단 3: netstat 명령어로 8080 포트 바인딩 및 프로그램 확인"
echo "$ sudo netstat -tulpn | grep :8080"
netstat -tulpn | grep :8080

echo ""
echo "[Step 5] Docker 컨테이너 포트 매핑 내역 대조 확인"
echo '$ docker ps --filter "publish=8080" --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'
docker ps --filter "publish=8080" --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "[Step 6] 포트 점유 해제 절차 수행 (충돌 컨테이너 삭제 및 기존 컨테이너 중지 후 포트 해제 검증)"
echo "$ docker rm -f conflict-test"
docker rm -f conflict-test
echo "$ docker stop my-web-8080"
docker stop my-web-8080
echo "$ sudo lsof -i :8080 || echo 'Port 8080 is now FREE (해제 완료)'"
lsof -i :8080 || echo "Port 8080 is now FREE (해제 완료)"
echo "$ sudo ss -tulpn | grep :8080 || echo 'No process listening on 8080'"
ss -tulpn | grep :8080 || echo "No process listening on 8080"

echo ""
echo "[Step 7] 해결 확인: 해제된 8080 포트로 컨테이너 재기동 및 대체 포트(8081) 할당 검증"
echo "$ docker start my-web-8080"
docker start my-web-8080
echo "$ sudo ss -tulpn | grep -E ':8080|:8081'"
ss -tulpn | grep -E ':8080|:8081'
echo "$ curl -I http://localhost:8080/health"
curl -sI http://localhost:8080/health | head -n 5

echo ""
echo "[보충 실험] 일반 호스트 프로세스(python3 http.server)가 8090 포트를 점유한 경우 kill 해제 절차"
python3 -m http.server 8090 >/dev/null 2>&1 &
sleep 1
echo "$ sudo lsof -i :8090"
lsof -i :8090
echo "$ sudo ss -tulpn | grep :8090"
ss -tulpn | grep :8090
echo "$ sudo netstat -tulpn | grep :8090"
netstat -tulpn | grep :8090
PID_8090=$(lsof -t -i :8090)
echo "$ sudo kill -9 $PID_8090"
kill -9 $PID_8090
sleep 1
echo "$ sudo lsof -i :8090 || echo 'Host process killed -> Port 8090 is now FREE'"
lsof -i :8090 || echo "Host process killed -> Port 8090 is now FREE"
