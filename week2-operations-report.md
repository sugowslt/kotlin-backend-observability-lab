# Project3 Week2 운영 리포트

기준일: 2026-03-05

## 1) 요약
- Week2 목표(탐지/알림/대응 속도 강화) 기준으로 알림 규칙, 안정성 설정, 장애 재현 드릴, 런북 사례화를 완료했다.
- 장애 재현 드릴에서 latency/error 탐지 시간을 실측해 운영 대응 근거를 확보했다.

## 2) 핵심 지표 요약 (30분 관측/드릴 구간 포함)

| 지표 | 값 | 산출 방식 |
|---|---:|---|
| 요청량 (`/api/v1/ops/events`) | 24,374.06 | `sum(increase(http_server_requests_seconds_count{uri='/api/v1/ops/events'}[30m]))` |
| 지연(참고, max latency) | 875.78ms(200), 1436.00ms(500) | `max_over_time(http_server_requests_seconds_max{uri='/api/v1/ops/events'}[30m]) * 1000` |
| 5xx 에러율 | 74.74% | `100 * 5xx increase / total increase` |

참고
- 본 수치는 장애 재현 드릴(강제 에러/지연 유도) 구간을 포함하므로 정상 운영 구간 대비 높게 관측됨.
- p95는 현재 계측 노출 특성상 직접 산출 대신 드릴 조건(`p95 > 200ms`) 충족 여부와 탐지 시간으로 운영 판단함.

## 3) 개선 전/후 비교

| 항목 | Week1(기반 구축) | Week2(운영 안정성 강화) |
|---|---|---|
| 경고 규칙 | 없음 | 3종 활성(latency/error/app down) |
| 탐지 정량 데이터 | 없음 | TTD 확보(latency 5.05s, error 25.02s) |
| 대응 문서 | 템플릿만 존재 | 실전 사례 1건 기록 완료 |

## 4) 결론
- Week2 DoD 관점에서 탐지 경로, 대응 사례, 다음 개선 과제를 모두 확보했다.
- 다음 단계는 경보 민감도 튜닝 및 드릴 반복 측정으로 경보 품질을 안정화하는 것이다.

## 5) 다음 개선 과제 3개
1. 드릴 전용 태그(trace/label) 도입으로 실험 트래픽과 일반 요청을 지표/로그에서 분리
2. latency/error alert의 `for` 및 rate/window 조합을 2안 이상 비교 실험
3. 드릴 3회 이상 반복 후 TTD 중앙값 기준 내부 운영 SLO 초안 확정
