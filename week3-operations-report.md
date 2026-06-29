# Project3 Week3 운영 리포트

기준일: 2026-03-05

## 1) 요약
- Week3 목표(경보 민감도 튜닝 + 드릴 반복 측정) 기준으로 ISSUE-1~3을 완료했다.
- 드릴 3회 반복 실행 결과를 확보했고, 중앙값 기반으로 탐지 특성을 정리했다.

## 2) 실행 정보
- 스크립트: `scripts/run-week3-drill-series.ps1`
- 결과 파일
  - `week3-drill-run-1.json`
  - `week3-drill-run-2.json`
  - `week3-drill-run-3.json`
  - `week3-drill-series-result.json`

## 3) TTD 결과 (3회 반복)

| Run | Latency TTD (sec) | Error TTD (sec) |
|---:|---:|---:|
| 1 | 10.02 | 30.03 |
| 2 | 0.00 | 10.00 |
| 3 | 0.00 | 10.01 |

중앙값(원본)
- Latency median: `0.00s`
- Error median: `10.01s`

보정 해석(운영 판단용)
- Latency 0초 2건은 이전 드릴 윈도우 값 잔존으로 시작 시점 즉시 조건 충족된 케이스다.
- `TTD > 0` 값만 기준으로 보면 Latency 탐지는 약 `10.02s` 수준으로 관찰된다.

## 4) Week2 대비 요약
- Week2 단일 드릴: latency 5.05s, error 25.02s
- Week3 반복 드릴(raw median): latency 0.00s, error 10.01s
- 결론: 에러 탐지는 반복 구간에서 더 빠르게 수렴했고, latency는 윈도우 잔존 영향 제거를 위한 쿨다운 정책이 필요하다.

## 5) 다음 액션 3개
1. 드릴 회차 간 쿨다운(예: 2~3분)과 baseline reset 구간을 스크립트에 추가
2. latency alert에 드릴 식별 라벨 기반 필터를 추가해 실험 영향 분리
3. Week4에서 정상 구간 오탐률과 탐지 지연을 함께 측정해 최종 alert profile 확정
