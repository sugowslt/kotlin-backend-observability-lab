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

관련 문서
- `activity-plan.md`
- `week1-issues.md`
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

## 11) Week 1 실행 순서
1. 운영 목표/지표 정의 (`operations-sli-goals.md`)
2. Spring Boot + Actuator/Micrometer + Docker Compose 초기화
3. 구조화 로그 + Trace ID/MDC 적용
4. Prometheus/Grafana 수집 경로 구성
5. CI 기본 파이프라인 구축

## 12) Week 1 DoD
- 운영 지표 수집 경로 확보
- 로그 추적 가능 상태 확보
- 장애 대응 문서 템플릿 생성
