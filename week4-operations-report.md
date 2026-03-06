# Project3 Week4 운영 리포트

기준일: 2026-03-06

## 1) 요약
- Week4 목표는 Week3 반복 드릴에서 발생한 윈도우 잔존 문제를 줄이고, 반복 측정 결과의 재현성을 높이는 것이었다.
- 쿨다운(`120s`)과 baseline recovery check를 적용한 3회 본측정에서 모든 run이 baseline 회복 후 시작되었고, Week3의 `latency 0s` 왜곡이 제거되었다.

## 2) 실행 정보
- 스크립트: `scripts/run-week3-drill-series.ps1`
- 실행 옵션
  - `ResultPrefix=week4-drill`
  - `Runs=3`
  - `CooldownSeconds=120`
  - `BaselineTimeoutSec=180`
  - `BaselineStablePolls=2`
- 결과 파일
  - `week4-drill-run-1.json`
  - `week4-drill-run-2.json`
  - `week4-drill-run-3.json`
  - `week4-drill-series-result.json`

## 3) TTD 결과 (3회 반복)

| Run | Baseline Recovered | Baseline Wait (sec) | Latency TTD (sec) | Error TTD (sec) |
|---:|:---:|---:|---:|---:|
| 1 | Yes | 5.02 | 15.01 | 20.01 |
| 2 | Yes | 20.01 | 10.00 | 15.02 |
| 3 | Yes | 15.01 | 10.00 | 15.01 |

중앙값
- Latency median: `10.00s`
- Error median: `15.02s`

## 4) Week3 대비 비교

| 항목 | Week3 | Week4 | 해석 |
|---|---:|---:|---|
| Latency median TTD | 0.00s(raw) | 10.00s | Week3 왜곡값이 제거되어 측정 신뢰도 향상 |
| Error median TTD | 10.01s | 15.02s | baseline 회복 대기와 보수적 프로필 영향으로 다소 증가 |
| Baseline recovery 기록 | 없음 | run별 기록 | 반복 실행 품질 검증 가능 |

## 5) 왜곡 요인 완화 여부
- 완화 성공: Week3에서 나타난 `latency 0s` 즉시 탐지 현상이 재현되지 않았다.
- 근거: 3회 모두 `baselineRecovered=true`이고, baseline 대기 후 측정이 시작되었다.
- 남은 한계: error 탐지는 보수적 기준(Profile-B)과 2분 윈도우 영향으로 latency 대비 늦게 관찰된다.

## 6) 최종 Alert profile 결론
- 최종 기본 운영 프로필은 `Profile-B`를 유지한다.
  - Latency: `window=2m`, `for=2m`, threshold `> 0.25s`
  - Error: `window=2m`, `for=2m`, threshold `> 2%`
- 이유
  1. 반복 드릴 기준으로 baseline 오염 제거 후에도 재현 가능한 탐지 결과를 제공함
  2. 단기 스파이크 오탐을 줄이는 방향이 현재 실습 환경 목적에 더 적합함
  3. 배포 직후/민감 시간대에는 `Profile-A`를 임시 적용하는 운영 전략을 유지할 수 있음

## 7) 다음 운영 개선 액션
1. 드릴 트래픽 식별 라벨 추가로 실험/일반 요청 지표 완전 분리
2. 정상 구간 30분 이상 관측으로 오탐률 기준 추가 확보
3. 배포 직후 자동으로 `Profile-A -> Profile-B` 전환하는 운영 절차 초안 작성
