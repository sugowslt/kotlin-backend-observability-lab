# Week2 Drill Result (ISSUE-3)

기준일: 2026-03-05

## 1) 드릴 목적
- 지연 급증/에러 급증 상황에서 탐지 시간(TTD, Time To Detect)을 측정한다.

## 2) 실행 방식
- 스크립트: `scripts/run-week2-drill.ps1`
- 결과 파일: `week2-drill-result.json`
- 측정 기준
  - Latency: `max_over_time(http_server_requests_seconds_max{uri='/api/v1/ops/events'}[1m]) > 0.2`
  - Error: `500 error rate > 1%`

## 3) 결과 요약

| Scenario | Condition | TTD (sec) |
|---|---|---:|
| latency-spike | max latency > 200ms | 5.05 |
| error-spike | 500 error rate > 1% | 25.02 |

## 4) 해석
- 지연 급증은 약 5초 내에 탐지되어 빠른 경고 경로가 확보됨.
- 에러 급증은 약 25초 후 탐지되어, 1분 윈도우 기반 rate 계산 특성상 지연이 존재함.

## 5) 다음 개선 포인트
- Alert `for`/window 조합을 환경에 맞게 세분화해 오탐/미탐 균형 조정
- Drill 반복 실행(최소 3회) 후 중앙값 기준으로 경보 SLO 정의
