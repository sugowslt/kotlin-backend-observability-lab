# Incident Response Template (Project3)

기준일: 2026-03-05

## 1) Incident 기본 정보
- Incident ID: P3-W2-INC-001
- 발생 일시: 2026-03-05 00:36:30 (KST)
- 탐지 일시: 2026-03-05 00:36:55 (KST)
- 종료 일시: 2026-03-05 00:38:10 (KST)
- 영향도(High/Medium/Low): Medium
- 영향 범위(사용자/API/기능): `POST /api/v1/ops/events` API

## 2) 증상 및 관측 지표
- 증상 요약: 장애 재현 드릴 중 에러율 급증과 응답 지연이 동시에 발생.
- 관련 SLI 변화:
  - p95 latency: 드릴 조건 기준 p95 > 200ms 충족(탐지 시간 5.05s)
  - Error rate: 5xx 비율 1% 초과 경고 발생(탐지 시간 25.02s)
  - Availability: 앱 다운은 없었고 `/actuator/health` 기준 UP 유지
- 관련 대시보드/메트릭:
  - Prometheus query:
    - `max_over_time(http_server_requests_seconds_max{uri='/api/v1/ops/events'}[1m]) > 0.2`
    - `sum(rate(http_server_requests_seconds_count{uri='/api/v1/ops/events',status=~'5..'}[1m])) / sum(rate(http_server_requests_seconds_count{uri='/api/v1/ops/events'}[1m])) > 0.01`
  - Grafana panel: Week2 초안 대시보드의 ops-events latency/error 패널

## 3) Trace/로그 근거
- 대표 traceId: 드릴 스크립트 기반 부하 재현 세션으로 단일 대표 traceId 지정 불가(요청 다건)
- 에러 코드: `INTERNAL_SERVER_ERROR` (강제 에러 유도 요청)
- 핵심 로그 3줄:
  1. `http.request.start method=POST path=/api/v1/ops/events traceId=...`
  2. `http.request.end status=500 path=/api/v1/ops/events traceId=...`
  3. `http.request.end status=200 path=/api/v1/ops/events traceId=... durationMs=...`

## 4) 원인 분석
- 직접 원인: 드릴 스크립트가 `forceError=true` 및 `delayMs`를 포함한 요청을 집중 생성.
- 근본 원인: 장애 재현 목적의 인위적 부하/오류 유발 시나리오 실행.
- 왜 사전에 탐지되지 않았는지: 운영 장애가 아닌 실험 이벤트였으며, 사전 공지 없이 실행 시 실제 장애로 오인될 여지가 있음.

## 5) 대응 및 복구
- 즉시 조치(Containment): 드릴 종료 시점에 에러 유발 요청 중단.
- 복구 조치(Recovery): 정상 요청만 재실행하여 에러율/지연 지표 정상화 확인.
- 검증 방법: `week2-drill-result.json`의 TTD 기록 + Prometheus rules API 상태 확인.

## 6) 재발 방지 액션
- 액션 1 (담당자/기한): 드릴 실행 전/후 공지 템플릿 운영 채널에 고정 (Owner: 본인, 2026-03-06)
- 액션 2 (담당자/기한): 드릴 전용 라벨(trace tag) 추가로 로그 분리 (Owner: 본인, 2026-03-07)
- 액션 3 (담당자/기한): latency/error alert의 `for`/window 재조정안 작성 (Owner: 본인, 2026-03-08)

## 7) 커뮤니케이션 로그
- 내부 공유 채널/시각: 개인 작업 로그(`SESSION_LOG.md`)에 즉시 기록 (2026-03-05 00:40 KST)
- 외부 공지(필요 시): 해당 없음(로컬 실습 환경)

## 8) 회고
- 잘된 점: alert rule 기반 탐지 경로와 TTD를 정량으로 확보함.
- 개선할 점: 단일 대표 traceId 추출이 어려워 드릴 식별 태그가 필요함.
- 다음 유사사건 대응 시 체크포인트: 드릴 시작/종료 시각, 탐지 시각, 복구 검증 쿼리를 반드시 한 세트로 기록.
