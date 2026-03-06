# project3-backend-observability-lab

운영·관측성 역량을 보여주기 위한 Kotlin Spring Boot 기반 실습 프로젝트입니다.

단순히 메트릭을 붙이는 수준이 아니라, Trace ID·구조화 로그·Prometheus·Grafana·Alert rule·반복 드릴·오탐률 점검까지 운영 루프를 하나의 흐름으로 정리했습니다.

## 1) 프로젝트 한눈에 보기
- Spring Boot + Actuator + Micrometer 기반 관측성 기본 구조 구성
- `X-Trace-Id` 기반 요청 추적과 표준 에러 응답 적용
- Prometheus 수집, Grafana 시각화, Alert rule 구성
- 장애 재현 드릴 자동화와 TTD(Time To Detect) 측정
- Drill 트래픽과 정상 트래픽을 `traffic_type` 라벨로 분리
- 정상 구간 오탐률까지 확인하며 운영 품질을 보강

## 2) 이 프로젝트에서 보여주려는 것
- 운영 지표를 코드와 문서로 정의하는 방식
- 로그, 메트릭, traceId를 같은 설명 흐름으로 묶는 방식
- 알림을 만들고 끝내지 않고 실제로 드릴해 보는 습관
- 관측 도구를 도입한 뒤 민감도와 오탐률까지 조정하는 과정

## 3) 기술 스택
- Language: Kotlin
- Framework: Spring Boot, Spring Validation, Spring Actuator
- Metrics: Micrometer, Prometheus
- Visualization: Grafana
- Infra: Docker Compose
- CI: GitHub Actions

관련 문서
- `operations-sli-goals.md`
- `incident-response-template.md`
- `stability-settings-week2.md`
- `week2-operations-report.md`
- `week3-alert-tuning-notes.md`
- `week3-operations-report.md`
- `week4-operations-report.md`
- `normal-traffic-false-positive-report.md`

## 4) 핵심 기능

### 4-1. 운영 API
- 이벤트 수신: `POST /api/v1/ops/events`

### 4-2. 추적
- `TraceIdFilter`로 `X-Trace-Id` 수신/생성
- 요청 시작/종료 로그 기록
- 응답 헤더와 에러 응답에 동일 `traceId` 포함

### 4-3. 메트릭
- `/actuator/prometheus` 노출
- Prometheus에서 앱 타깃 scrape
- Grafana에서 Request Rate, p95, Error Rate, JVM 지표 시각화

### 4-4. 운영 드릴
- latency spike / error spike 드릴 실행
- TTD 측정 결과를 JSON/Markdown으로 기록
- 반복 드릴 시 baseline 회복 여부까지 체크

### 4-5. 트래픽 분리
- `X-Traffic-Type` 헤더 기반으로 `traffic_type` 메트릭 라벨 추가
- drill / normal 트래픽을 분리해 경보 오염 방지

## 5) 실행 가이드

### 5-1. 사전 준비
- JDK 17
- Docker Desktop

### 5-2. 앱 실행
```powershell
cd app
.\gradlew.bat test
.\gradlew.bat bootRun
```

기본 확인
- Health: `http://localhost:8080/actuator/health`
- Prometheus metrics: `http://localhost:8080/actuator/prometheus`

### 5-3. 관측 스택 실행
```powershell
docker compose up -d
```

확인 주소
- Prometheus: `http://localhost:19090`
- Grafana: `http://localhost:13000` (`admin/admin`)

## 6) 빠른 확인 순서
1. 앱 실행 후 `/actuator/health` 확인
2. Docker Compose로 Prometheus, Grafana 실행
3. `/actuator/prometheus` 응답 확인
4. Prometheus `targets`에서 `project3-app`이 `UP`인지 확인
5. Grafana 대시보드에서 메트릭이 들어오는지 확인

이 흐름만 따라가도
"앱 -> 메트릭 노출 -> 수집 -> 시각화"가 모두 살아 있는지 바로 확인할 수 있습니다.

## 7) 시연 포인트

### 7-1. traceId 흐름
- `POST /api/v1/ops/events` 호출
- 응답의 `traceId` 확인
- 로그의 `http.request.start`, `http.request.end`와 연결해서 설명

### 7-2. Grafana / Prometheus
- Grafana에서는 메트릭 추이와 알림 흐름을 설명
- Prometheus에서는 실제 수집 상태, targets, rule, query를 확인

### 7-3. drill 시연
- 드릴 스크립트로 latency / error spike 유발
- Prometheus 쿼리와 Alert rule이 얼마나 빨리 반응하는지 확인
- 결과 파일에서 TTD를 읽어 설명

## 8) 단계별 진행 결과 요약

### Week 1
- 운영 목표와 SLI 정의
- 프로젝트 초기화
- 구조화 로그 + traceId 적용
- 메트릭 노출 + Prometheus/Grafana 연결
- GitHub Actions CI 기본 파이프라인 구성

### Week 2
- Prometheus Alert rule 기본 세트 구성
- Graceful shutdown / timeout 설정 반영
- 장애 재현 드릴 1차 수행
- 운영 리포트 작성

실측 예시
- latency-spike TTD: `5.05s`
- error-spike TTD: `25.02s`

### Week 3
- Alert 민감도 튜닝
- 반복 드릴 자동화
- 운영 리포트 작성

### Week 4
- baseline reset / cooldown 자동화
- 보정 드릴 3회 본측정
- 최종 Alert profile 정리

실측 요약
- Latency median: `10.00s`
- Error median: `15.02s`

## 9) 최종 안정화 보강
- drill / normal 트래픽 라벨 분리 완료
- Alert rule은 `traffic_type=normal` 기준으로만 평가
- 정상 구간 오탐률 점검 완료
- `180초`, `30회 poll` 기준 false positive `0건`

이 부분이 중요한 이유는,
실험용 트래픽 때문에 실제 운영 알림 해석이 흔들리지 않도록 설계했다는 점을 보여주기 때문입니다.

## 10) 주요 파일과 산출물
- `prometheus/prometheus.yml`: scrape 설정
- `prometheus/alerts.yml`: alert rule
- `grafana-dashboard-draft.json`: 대시보드 초안
- `scripts/run-week2-drill.ps1`: 드릴 1차 스크립트
- `scripts/run-week3-drill-series.ps1`: 반복 드릴 자동화
- `normal-traffic-false-positive-result.json`: 오탐 점검 결과

## 11) 트러블슈팅 요약

### 주요 사례
- Prometheus rules가 비어 보이는 문제
  - 원인: `alerts.yml` 마운트 누락
  - 해결: `docker-compose.yml`에 볼륨 추가
- histogram 부재로 p95 query가 동작하지 않는 문제
  - 원인: summary 중심 메트릭 노출
  - 해결: `http_server_requests_seconds_max` 기반으로 drill / alert 전환
- 반복 드릴 중 `bootRun` 종료
  - 원인: Gradle daemon 메모리 오버헤드
  - 해결: `bootJar` 후 `java -jar` 경로로 전환
- 반복 드릴에서 latency TTD가 `0s`로 왜곡
  - 원인: 이전 run의 윈도우 값 잔존
  - 해결: cooldown + baseline recovery 체크 추가
- drill 트래픽이 운영 경보를 오염시키는 문제
  - 원인: 실험 트래픽과 정상 트래픽이 동일 시계열 집계
  - 해결: `X-Traffic-Type`, `traffic_type` 라벨 도입

## 12) 이 프로젝트를 볼 때 좋은 포인트
- 메트릭 노출보다 그 이후의 운영 루프가 더 중요하다는 점
- 경보를 한 번 만들고 끝내지 않고 반복 실험으로 조정한 점
- traceId, 로그, 메트릭, 드릴 결과를 서로 연결해 설명할 수 있다는 점
- 오탐률까지 따져서 실제 운영에 가까운 품질을 목표로 했다는 점

## 13) 포트폴리오 시연 연결
- `project1/dashboard`에서 전체 흐름 소개
- `project3`에서는 Grafana와 Prometheus를 열어 운영 관측 흐름 설명
- 필요하면 `project1`의 `traceId`, `project2`의 이벤트 흐름과 연결해
  "요청 처리 -> 이벤트 처리 -> 운영 관측" 전체 그림을 완성할 수 있습니다.

## 14) 현재 상태
- 핵심 구현, 드릴, 경보 튜닝, 운영 리포트, 오탐 점검까지 완료
- 포트폴리오용 설명과 재현이 가능한 상태
- 이후 작업은 선택적 polish 범위

## 라이선스
MIT License. 자세한 내용은 `LICENSE` 파일을 참고하세요.
