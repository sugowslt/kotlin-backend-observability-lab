# Project3 - Week 4 이슈

## 주간 목표
- Week3 반복 드릴의 측정 왜곡 요인을 줄이고, 경보 탐지 결과의 재현성을 높인다.

## 이슈 목록 (체크리스트)

### ISSUE-1: 드릴 쿨다운 + baseline reset 자동화
- [x] 회차 간 쿨다운 파라미터 추가
- [x] 드릴 시작 전 baseline 회복 체크 로직 추가
- [x] run 결과 JSON에 baseline 회복 여부/대기시간 기록

완료 기준
- 스크립트 단일 실행 시 회차별 baseline 회복 상태를 확인할 수 있음

산출물
- `scripts/run-week3-drill-series.ps1`

검증 메모
- 스모크 실행(축소 파라미터)으로 baseline 회복 상태 기록 확인
- 확인 항목:
	- `baselineRecovered`, `baselineWaitSeconds`가 run별 JSON/요약 JSON에 포함됨
	- baseline 미회복 시 경고 로그 출력 후 다음 run 진행됨

---

### ISSUE-2: 보정 드릴 3회 실행 및 결과 수집
- [ ] 쿨다운/baseline 옵션 적용 상태로 3회 실행
- [ ] `week4-drill-run-*.json` 저장
- [ ] 중앙값 집계(`week4-drill-series-result.json`) 생성

진행 메모
- 축소 파라미터 스모크에서는 run2~3에서 baseline 미회복 경고 발생
- Week4 본측정 시 쿨다운/타임아웃 상향(예: cooldown 120s, baseline timeout 180s 이상) 필요

완료 기준
- Latency/Error TTD 중앙값을 Week3와 비교 가능한 포맷으로 확보

산출물
- `week4-drill-run-1.json`
- `week4-drill-run-2.json`
- `week4-drill-run-3.json`
- `week4-drill-series-result.json`

---

### ISSUE-3: Week4 운영 리포트
- [ ] 왜곡 요인(윈도우 잔존) 완화 여부 정리
- [ ] Week3 대비 수치 비교
- [ ] 최종 Alert profile 확정 또는 잔여 액션 정의

완료 기준
- Week4 종료 리포트 1개 완성

산출물
- `week4-operations-report.md`

## Week 4 DoD
- [ ] 드릴 회차 간 baseline 오염 이슈 완화
- [ ] 반복 실행 중앙값 확보
- [ ] 최종 운영 개선 액션 확정
