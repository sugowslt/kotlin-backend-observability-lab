# Week3 Alert Tuning Notes

기준일: 2026-03-05

## 1) 튜닝 목표
- 탐지 속도(TTD)를 유지하면서 드릴/실험 트래픽으로 인한 오탐을 줄인다.

## 2) 후보안

### Profile-A (빠른 탐지 우선)
- Latency: `window=1m`, `for=1m`, threshold `> 0.2s`
- Error: `window=1m`, `for=1m`, threshold `> 1%`
- 기대 효과: 탐지는 빠르지만 단기 스파이크 오탐 가능성 증가

### Profile-B (안정성 우선)
- Latency: `window=2m`, `for=2m`, threshold `> 0.25s`
- Error: `window=2m`, `for=2m`, threshold `> 2%`
- 기대 효과: 오탐은 감소하지만 탐지 지연 가능성 증가

## 3) 선택 기준
- 기준 1: 드릴 3회 중앙값 TTD(낮을수록 우수)
- 기준 2: 정상 구간 오탐 횟수(적을수록 우수)
- 기준 3: 장애 종료 후 정상 복귀 시간(짧을수록 우수)

## 4) 적용 전략
- 기본은 Profile-B로 유지하고, 장애 민감 구간(배포 직후 등)에는 Profile-A를 임시 적용한다.
- Week3 드릴 3회 결과를 보고 최종 운영 기본값을 확정한다.
