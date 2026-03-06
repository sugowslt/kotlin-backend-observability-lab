# project3-backend-observability-lab

운영/관측성 역량 증명을 위한 Kotlin Spring Boot 기반 실습 프로젝트입니다.

## 1) 프로젝트 목표
- 운영 관점 핵심 지표(SLI) 정의 및 측정 경로 확보
- 구조화 로그 + Trace ID 기반 추적 가능 상태 구축
- 메트릭 수집/시각화/장애 대응 문서까지 연결된 운영 루프 구현

## 2) 현재 상태 (Week 1 시작)
- ISSUE-1 완료: 운영 목표/지표 정의
- ISSUE-2 완료: 프로젝트/환경 초기화(Spring Boot + Actuator/Micrometer + Docker Compose)
- ISSUE-3 완료: 구조화 로그 + Trace ID/MDC + 표준 에러 필드
- ISSUE-4 완료: 메트릭 노출 + Prometheus 수집 + Grafana 대시보드 초안
- ISSUE-5 완료: GitHub Actions CI 기본 파이프라인
- Week 1 DoD 완료
- Week 2 ISSUE-1 완료: Prometheus 알림 규칙 기본 세트

관련 문서
- `activity-plan.md`
- `week1-issues.md`
- `week2-issues.md`
- `operations-sli-goals.md`

## 3) ISSUE-2 완료 결과
- 산출물
  - `app/` (Spring Boot Kotlin 프로젝트)
  - `app/build.gradle.kts` (Actuator + Prometheus Micrometer 의존성)
  - `app/src/main/resources/application.yml` (health/info/metrics/prometheus 노출)
  - `docker-compose.yml` (Prometheus + Grafana 기본 구성)
  - `prometheus/prometheus.yml` (앱 메트릭 scrape 설정)
- 검증
  - `cd app && .\gradlew.bat test`
  - `cd app && .\gradlew.bat bootRun`
  - `GET http://localhost:8080/actuator/health` 응답 확인

## 4) 로컬 실행 가이드
1. 앱 실행
	- `cd app`
	- `.\gradlew.bat bootRun`
2. 헬스체크
	- `http://localhost:8080/actuator/health`
3. 관측 스택 실행
	- `docker compose up -d`
4. 확인 URL
	- Prometheus: `http://localhost:19090`
	- Grafana: `http://localhost:13000` (admin/admin)

## 5) ISSUE-3 완료 결과
- 구현
  - Trace ID 필터(`TraceIdFilter`) 적용: `X-Trace-Id` 수신/생성 + MDC 저장 + 응답 헤더 반환
  - 요청 시작/종료 구조화 로그: `http.request.start`, `http.request.end`
  - 에러 표준 필드 응답: `status`, `errorCode`, `message`, `path`, `traceId`
  - 테스트용 API: `POST /api/v1/ops/events`
- 검증
  - `cd app && .\gradlew.bat test`
  - `cd app && .\gradlew.bat bootRun`
  - 정상 요청: `POST /api/v1/ops/events` -> 응답에 `traceId` 확인
  - 실패 요청(빈 필드): `errorCode=VALIDATION_FAILED`, `traceId` 포함 응답 확인

## 6) ISSUE-4 완료 결과
- 구현
  - `application.yml`에서 `/actuator/prometheus` 노출 유지
  - `prometheus/prometheus.yml`에서 `project3-app` scrape 설정 유지
  - Grafana 초안 대시보드 파일 추가: `grafana-dashboard-draft.json`
- 검증
  - `GET http://localhost:8080/actuator/prometheus` 응답 확인
  - `GET http://localhost:19090/api/v1/targets`에서 `project3-app` 타깃 `health=up` 확인

## 7) Grafana 대시보드 초안
- 파일: `grafana-dashboard-draft.json`
- 포함 패널
  - Request Rate (req/s)
  - p95 Latency (ms)
  - 5xx Error Rate (%)
  - JVM Heap Memory Used (MB)

## 8) ISSUE-5 완료 결과
- 구현
  - GitHub Actions 워크플로우 추가: `.github/workflows/ci.yml`
  - 파이프라인 단계: `test` -> `build`
  - 실행 경로: `./app/gradlew -p ./app ...`
- 실패 시 로그 확인 경로
  - GitHub Repository > **Actions** 탭
  - 실패한 workflow run 선택
  - `build-test` job > 실패한 step의 로그 펼쳐서 확인

## 9) 장애 대응 템플릿
- 파일: `incident-response-template.md`
- 포함 항목
  - 지표/로그/traceId 근거
  - 원인 분석(직접 원인/근본 원인)
  - 복구 조치 및 재발 방지 액션

## 10) Week 1 최종 상태
- ISSUE-1~5 완료
- Week 1 DoD 3개 항목 완료
- 다음 시작점: Week 2(운영 안정성 강화)

## 11) Week 2 진행 상태
- ISSUE-1 완료: Prometheus 알림 규칙 기본 세트
- 구현
  - `prometheus/alerts.yml` (p95 latency / 5xx error / app down)
  - `prometheus/prometheus.yml`의 `rule_files` 반영
  - `docker-compose.yml`에 `alerts.yml` 마운트 추가
- 검증
  - `GET http://localhost:19090/api/v1/rules`에서 `project3-observability-rules` 그룹 조회 확인
  - rules API에서 3개 alert rule(`Project3HighLatencyP95`, `Project3HighErrorRate`, `Project3AppDown`) 확인
- ISSUE-2 완료: Timeout/Graceful Shutdown 기본값 적용
- 구현
  - `application.yml`: graceful shutdown + timeout 기본값 반영
  - 운영 문서: `stability-settings-week2.md`
- 검증
  - `cd app && .\gradlew.bat test` 통과
  - `GET /actuator/health` 응답 `UP` 확인
- ISSUE-3 완료: 장애 재현 드릴 1차 + TTD 기록
- 구현
  - 드릴 스크립트: `scripts/run-week2-drill.ps1`
  - 결과: `week2-drill-result.json`, `week2-drill-result.md`
- 실측 결과
  - latency-spike TTD: 5.05s
  - error-spike TTD: 25.02s
- 트러블슈팅
  - 원인: `http_server_requests_seconds_bucket` 미노출(summary 타입만 노출)
  - 해결: latency alert/query를 `http_server_requests_seconds_max` 기반으로 전환
- ISSUE-4 완료: 런북 템플릿 실전 사례 채우기
- 구현
  - `incident-response-template.md`에 실전 사례 1건 기록(원인/대응/재발방지/지표 근거 포함)
- 검증
  - Incident 필수 항목(증상/근거/원인/복구/액션) 모두 채움
- ISSUE-5 완료: Week2 운영 리포트 작성
- 구현
  - `week2-operations-report.md` 작성(요청량/지연/에러율, 전후 비교, 다음 과제 3개)
- Week 2 최종 상태
  - ISSUE-1~5 완료
  - Week 2 DoD 3개 항목 완료
  - 다음 시작점: Week 3(경보 튜닝 + 드릴 반복 측정)

## 12) Week 1 실행 순서
1. 운영 목표/지표 정의 (`operations-sli-goals.md`)
2. Spring Boot + Actuator/Micrometer + Docker Compose 초기화
3. 구조화 로그 + Trace ID/MDC 적용
4. Prometheus/Grafana 수집 경로 구성
5. CI 기본 파이프라인 구축

## 13) Week 1 DoD
- 운영 지표 수집 경로 확보
- 로그 추적 가능 상태 확보
- 장애 대응 문서 템플릿 생성

## 14) Week 3 진행 상태
- ISSUE-1 완료: 경보 민감도 튜닝안 정의 및 1차 적용
- 구현
  - `week3-alert-tuning-notes.md` (Profile-A/Profile-B, 선택 기준)
  - `prometheus/alerts.yml` 기준값 조정(latency 250ms, error 2%)
- ISSUE-2 완료: 장애 재현 드릴 3회 반복 자동화
- 구현
  - `scripts/run-week3-drill-series.ps1`
  - 실행 시 `week3-drill-run-1..N.json`, `week3-drill-series-result.json` 자동 생성
- ISSUE-3 완료: Week3 운영 리포트 작성
- 구현
  - `week3-operations-report.md` (중앙값 TTD, 전/후 비교, 다음 액션 3개)
- Week 3 최종 상태
  - ISSUE-1~3 완료
  - Week 3 DoD 3개 항목 완료
  - 다음 시작점: Week 4(쿨다운/리셋 포함 드릴 품질 고도화)

## 15) Week 4 진행 상태
- ISSUE-1 완료: 드릴 쿨다운 + baseline reset 자동화
- 구현
  - `scripts/run-week3-drill-series.ps1`에 `CooldownSeconds`, `BaselineTimeoutSec`, `BaselineStablePolls` 파라미터 추가
  - run 시작 전 baseline 회복 체크 로직 추가
  - run 결과에 `baselineRecovered`, `baselineWaitSeconds` 기록
  - 스크립트 절대경로 의존 제거(스크립트 위치 기반 경로 계산)
- 검증
  - 축소 파라미터 스모크 실행으로 결과 JSON/경고 로그 확인

### Week4 드릴 실행 예시
```powershell
Set-Location .\project3
.\scripts\run-week3-drill-series.ps1 `
  -BaseUrl http://localhost:8080 `
  -PrometheusUrl http://localhost:19090 `
  -Runs 3 `
  -CooldownSeconds 120 `
  -BaselineTimeoutSec 180 `
  -BaselineStablePolls 2
```

### Week4 다음 작업
- ISSUE-2 완료: 보정 드릴 3회 본측정
- 구현
  - `week4-drill-run-1.json`, `week4-drill-run-2.json`, `week4-drill-run-3.json`
  - `week4-drill-series-result.json`
- 검증
  - 3회 모두 `baselineRecovered=true`
  - Latency median 10.00s, Error median 15.02s
- ISSUE-3 완료: Week4 운영 리포트 작성 및 최종 Alert profile 정리
- 구현
  - `week4-operations-report.md`
  - 최종 기본 운영 프로필: Profile-B 유지(`latency > 250ms / 2m`, `error rate > 2% / 2m`)
- Week 4 최종 상태
  - ISSUE-1~3 완료
  - Week 4 DoD 3개 항목 완료
  - 다음 시작점: 정상 구간 오탐률 측정 + 드릴 트래픽 식별 라벨 추가

## 16) 최종 운영 안정화 보강
- 드릴/정상 트래픽 라벨 분리 완료
  - 앱 요청 헤더 `X-Traffic-Type` 기반으로 `traffic_type` 메트릭 라벨 추가
  - Drill 스크립트는 `traffic_type=drill`, 일반 요청은 `traffic_type=normal`으로 기록
  - Alert rule은 `traffic_type=normal` 기준으로만 평가되도록 조정
- 정상 구간 오탐률 점검 완료
  - 산출물: `normal-traffic-false-positive-result.json`, `normal-traffic-false-positive-report.md`
  - 결과: 180초 관측, 30회 poll, false positive `0건`
- 현재 상태
  - `project3` 핵심 구현/실험/운영 문서화 완료
  - 다음 단계는 선택적 포트폴리오 polish(면접 요약/운영 절차 자동화) 범위

## 17) 상세 트러블슈팅 기록

### Case 1. Prometheus rules가 비어 보이는 문제
- 증상
  - `GET /api/v1/rules`에서 rule group이 비어 있고 alert rule이 보이지 않음
- 원인
  - `prometheus/alerts.yml`이 컨테이너에 마운트되지 않아 `rule_files`가 실제로 로드되지 않음
- 해결
  - `docker-compose.yml`에 `./prometheus/alerts.yml:/etc/prometheus/alerts.yml:ro` 볼륨을 추가하고 재기동
- 선택 이유
  - Prometheus 설정 파일 구조를 바꾸지 않고 실제 누락된 파일 연결만 복구하는 최소 수정이었음

### Case 2. latency p95를 histogram으로 계산할 수 없는 문제
- 증상
  - `http_server_requests_seconds_bucket`가 없어 기존 p95 쿼리/alert가 동작하지 않거나 `ttdSeconds=-1`이 반복됨
- 원인
  - 현재 노출 메트릭이 histogram이 아니라 summary(`count/sum/max`) 중심으로 제공됨
- 해결
  - latency drill/alert/query를 `http_server_requests_seconds_max` 기반으로 전환
- 선택 이유
  - 계측 라이브러리나 메트릭 구조를 대규모로 바꾸지 않고, 현재 노출 지표만으로 재현 가능한 탐지 경로를 확보할 수 있었음

### Case 3. 드릴 중 `bootRun`이 GC thrashing으로 종료되는 문제
- 증상
  - 반복 드릴 도중 `Gradle build daemon has been stopped: since the JVM garbage collector is thrashing` 오류로 앱이 종료됨
- 원인
  - `bootRun`은 Gradle 데몬 오버헤드가 포함되어 반복 부하 상황에서 메모리 압박이 더 크게 누적됨
- 해결
  - `bootJar` 후 `java -Xms128m -Xmx512m -jar ...` 방식으로 앱 실행 경로를 전환
- 선택 이유
  - 운영에 가까운 실행 방식으로 바꾸면서 측정 안정성을 확보하고, Gradle 런타임 영향도 분리할 수 있었음

### Case 4. Week3 반복 드릴에서 latency TTD가 `0s`로 왜곡되는 문제
- 증상
  - Week3 드릴 3회 중 2회에서 latency median이 `0.00s`로 집계되어 실제 탐지 시간 해석이 어려움
- 원인
  - 이전 run의 윈도우 값이 남아 시작 직후 조건이 즉시 참으로 평가됨
- 해결
  - `CooldownSeconds`, `BaselineTimeoutSec`, `BaselineStablePolls`를 도입해 run 시작 전 baseline 회복을 강제
- 선택 이유
  - 쿼리 자체를 왜곡 없이 유지하면서 실행 순서와 측정 조건만 제어해 재현성을 높이는 방법이 가장 안전했음

### Case 5. Docker Desktop 엔진 미기동으로 본측정이 막히는 문제
- 증상
  - `docker compose up -d`가 pipe 연결 오류와 함께 실패함
- 원인
  - Windows에서 Docker Desktop 엔진이 내려간 상태였음
- 해결
  - Docker Desktop 앱을 먼저 기동하고, `docker version`으로 engine readiness를 확인한 뒤 관측 스택을 재실행
- 선택 이유
  - Week4 본측정은 Prometheus query 기반이라 Docker 엔진이 필수였고, 환경 복구가 가장 직접적인 해결책이었음

### Case 6. drill 트래픽이 정상 운영 경보를 오염시키는 문제
- 증상
  - 실험용 drill 요청이 정상 운영 latency/error alert에 함께 반영되어 오탐 해석이 어려움
- 원인
  - `/api/v1/ops/events` 메트릭이 drill/normal 요청을 동일 시계열로 집계하고 있었음
- 해결
  - `X-Traffic-Type` 헤더와 `traffic_type` 메트릭 라벨을 추가하고, alert/query를 `traffic_type=normal` 기준으로 분리
- 선택 이유
  - 서비스 엔드포인트를 나누지 않고도 운영/실험 트래픽을 메트릭 차원에서 구분할 수 있어 유지비용이 가장 낮았음
