# Project3 - Week 3 이슈

## 주간 목표
- Week2에서 확보한 탐지/대응 기반을 실제 운영 튜닝(경보 민감도 + 반복 측정) 단계로 고도화한다.

## 이슈 목록 (체크리스트)

### ISSUE-1: 경보 민감도 튜닝안 2개 정의
- [x] Latency alert `for/window` 조합안 2개 정의
- [x] Error alert `for/window` 조합안 2개 정의
- [x] 적용 기준(오탐/미탐/탐지속도) 문서화

완료 기준
- 튜닝안 2개 이상이 문서화되어 있고 선택 기준이 명확함

산출물
- `prometheus/alerts.yml`
- `week3-alert-tuning-notes.md`

---

### ISSUE-2: 장애 재현 드릴 3회 반복 자동화
- [x] 드릴 3회 반복 실행 스크립트 작성
- [x] 회차별 결과 JSON 자동 저장
- [x] 중앙값 집계 JSON 자동 생성

완료 기준
- 단일 명령으로 3회 드릴 + 집계까지 수행 가능

산출물
- `scripts/run-week3-drill-series.ps1`

---

### ISSUE-3: Week3 운영 리포트
- [x] 중앙값 기준 TTD 요약
- [x] 튜닝 전/후 비교
- [x] 다음 액션 3개 정의

완료 기준
- Week3 종료 리포트 1개 완성

산출물
- `week3-operations-report.md`

## Week 3 DoD
- [x] 경보 민감도 튜닝안 확정
- [x] 드릴 반복 측정 중앙값 확보
- [x] 다음 운영 개선 백로그 확정
