# backend-observability-lab

Spring Actuator + Prometheus + Grafana로 운영 관측 파이프라인을 만든 실습 프로젝트입니다.
대시보드만 띄우는 데서 그치지 않고, alert 드릴, false positive 점검, traffic 분리까지 직접 운영해봤어요.

## 무엇을 해결했나

- `X-Trace-Id` 기반 요청 추적
- 구조화 로그 + 표준 에러 응답
- Prometheus 수집 + Grafana 시각화
- alert rule 설정 및 반복 드릴
- `X-Traffic-Type` 기반 `traffic_type` 라벨 분리
- 정상 구간 false positive 점검: 0건

드릴 트래픽이 운영 지표를 오염시키면 알림 튜닝 자체가 의미가 없어진다고 생각해서, traffic 분리부터 먼저 적용했어요.

## 기술 스택

- Kotlin + Spring Boot
- Spring Actuator, Micrometer
- Prometheus, Grafana
- Docker Compose
- GitHub Actions(CI)

## 실행 방법

### 앱 실행

```bash
cd app
./gradlew bootRun
```

확인:
- Health: `http://localhost:8080/actuator/health`
- Metrics: `http://localhost:8080/actuator/prometheus`

### 관측 스택 실행

```bash
docker compose up -d
```

확인:
- Prometheus: `http://localhost:19090`
- Grafana: `http://localhost:13000` (`admin/admin`)

## clone만 해도 바로 보기

루트에 `viewer.html`을 넣어뒀어요. clone만 해도 브라우저로 바로 열 수 있습니다.

```bash
git clone git@github.com:sugowslt/kotlin-backend-observability-lab.git
open kotlin-backend-observability-lab/viewer.html
```

## 트러블슈팅

- Prometheus rules 미노출: compose 볼륨 마운트가 누락되어서 추가했어요.
- histogram 미노출로 p95 query 실패: summary 중심 메트릭이라 `http_server_requests_seconds_max`로 전환했습니다.
- 반복 드릴에서 TTD 0초 왜곡: 이전 run 윈도우 잔존 문제로, cooldown + baseline recovery 체크를 추가했어요.
- drill 트래픽이 운영 경보 오염: `X-Traffic-Type`, `traffic_type` 라벨을 도입해서 해결했습니다.
