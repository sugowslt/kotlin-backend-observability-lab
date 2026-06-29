# Project3 운영 목표/지표 정의 (ISSUE-1)

기준일: 2026-03-04

## 1) 운영 SLI 3개

### SLI-1: API 응답시간(p95)
- 정의: `POST /api/v1/ops/events` 요청의 p95 latency
- 목표: p95 <= 200ms (로컬/단일 인스턴스 기준)
- 수집 경로: Spring Actuator + Micrometer(`http.server.requests`)

### SLI-2: 에러율(Error Rate)
- 정의: HTTP 5xx 비율
- 목표: Error Rate <= 1.0%
- 수집 경로: Actuator metrics + 로그 집계

### SLI-3: 가용성(Health Availability)
- 정의: 측정 구간 내 `/actuator/health` 성공 응답 비율
- 목표: Availability >= 99.0% (개발환경 실험 기준)
- 수집 경로: 헬스체크 스크립트(주기 호출) + 로그

## 2) 수집 주기/방법
- 메트릭 수집 주기
  - Actuator scrape: 15초
  - Health check ping: 10초
- 집계 주기
  - 세션 단위(30~60분) 1회 집계
  - 이슈 완료 시 비교 요약 표 갱신
- 결과 저장 위치
  - 정량 결과: `project3/perf/` 또는 루트 결과 JSON
  - 해석/결론: `README.md`, 주차 문서

## 3) 장애 시나리오 2개

### 시나리오 A: 다운스트림 지연/타임아웃
- 증상: 응답시간 급증, 타임아웃, p95 상승
- 관찰 포인트
  - p95 latency 증가
  - 5xx 비율 상승
  - timeout 관련 에러 로그 증가
- 대응 계획
  - timeout/retry 정책 점검
  - 장애 시간대 traceId 샘플링 분석

### 시나리오 B: 예외 폭증(애플리케이션 에러)
- 증상: 특정 배포/변경 이후 5xx 급증
- 관찰 포인트
  - Error Rate 급상승
  - 동일 예외 시그니처 반복
  - health는 정상이나 비즈니스 API 실패 증가
- 대응 계획
  - 에러 로그 표준 필드(traceId, endpoint, errorCode) 기반 그룹화
  - 최근 변경분 롤백/핫픽스 판단

## 4) 완료 판단
- SLI 3개 정의 및 목표값이 문서화됨
- 지표 수집 경로/주기/저장 위치가 명시됨
- 장애 시나리오 2개가 관찰 포인트와 대응 계획까지 정의됨
