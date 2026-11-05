FROM nginx:alpine

# 1. 메타데이터 라벨 추가 (이미지 관리 및 식별 목적)
LABEL org.opencontainers.image.title="workstation-custom-web" \
      org.opencontainers.image.description="Custom NGINX Web Server for Dev Workstation Mission" \
      org.opencontainers.image.version="1.0"

# 2. 환경 변수 설정 (설정과 코드의 분리 및 시간대/환경 지정)
ENV APP_ENV=production \
    APP_PORT=80 \
    TZ=Asia/Seoul

# 3. 헬스체크에 필요한 curl 패키지 설치
RUN apk add --no-cache curl

# 4. 커스텀 NGINX 설정 및 정적 웹 콘텐츠 복사
COPY app/default.conf /etc/nginx/conf.d/default.conf
COPY app/index.html /usr/share/nginx/html/index.html

# 5. 컨테이너 헬스체크 구성 (서비스 상태 자동 점검)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${APP_PORT}/health || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

