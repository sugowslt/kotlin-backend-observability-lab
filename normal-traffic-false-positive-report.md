# Normal Traffic False Positive Check

기준일: 2026-03-06

## 1) 목적
- 정상 구간에서 `Project3HighLatencyP95`, `Project3HighErrorRate` 경보가 불필요하게 발화하는지 확인한다.

## 2) 실행 정보
- 스크립트: `scripts/run-normal-traffic-false-positive-check.ps1`
- 결과 파일: `normal-traffic-false-positive-result.json`
- 실행 조건
  - Duration: `180s`
  - Request interval: `1000ms`
  - Poll interval: `5s`
  - Traffic type header: `X-Traffic-Type=normal`

## 3) 결과 요약
- 총 요청 수: `30`
- 총 poll 수: `30`
- false positive count: `0`
- false positive rate: `0.0`

## 4) 해석
- 3분 정상 트래픽 관측 구간에서 latency/error 경보의 firing 이벤트는 발생하지 않았다.
- `traffic_type` 라벨 분리 후 drill 트래픽과 정상 트래픽이 메트릭에서 분리됨을 확인했다.
- 현재 기본 운영 프로필(Profile-B)은 실습 환경 기준에서 정상 구간 오탐 없이 유지 가능하다.
