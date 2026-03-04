# Project3 - Week 2 이슈

## 주간 목표
- 관측성 기반을 바탕으로 운영 안정성(탐지/알림/대응 속도)을 강화한다.

## 이슈 목록 (체크리스트)

### ISSUE-1: Prometheus 알림 규칙 기본 세트
- [x] p95 latency 경고 규칙 추가
- [x] 5xx error rate 경고 규칙 추가
- [x] 앱 다운(Up=0) 경고 규칙 추가

완료 기준
- Prometheus rules API에서 rule group이 조회되고 활성 상태 확인

산출물
- `prometheus/alerts.yml`
- `prometheus/prometheus.yml` (`rule_files` 반영)

---

### ISSUE-2: 앱 안정성 설정(Timeout/Graceful Shutdown)
- [x] 서버 graceful shutdown 설정
- [x] 요청 타임아웃 정책 기본값 정의
- [x] 운영용 설정 문서화

완료 기준
- 설정 적용 후 재기동/종료 시나리오 문서 확인

산출물
- `app/src/main/resources/application.yml`
- `stability-settings-week2.md`

---

### ISSUE-3: 장애 재현 드릴 1차
- [x] 지연 시나리오 재현 스크립트 작성
- [x] 에러율 급증 시나리오 재현
- [x] 탐지 시간(TTD) 기록

완료 기준
- 드릴 결과 기록 문서 1개 작성

산출물
- `scripts/run-week2-drill.ps1`
- `week2-drill-result.json`
- `week2-drill-result.md`

---

### ISSUE-4: 런북 템플릿 실전 채우기
- [x] `incident-response-template.md` 실제 예시 1건 작성
- [x] 원인/대응/재발방지 액션 채우기
- [x] 운영 지표 링크 첨부

완료 기준
- 면접 설명 가능한 장애 대응 사례 1건 확보

---

### ISSUE-5: 운영 리포트(Week1~2)
- [x] 핵심 지표 요약(요청량/p95/에러율)
- [x] 개선 전/후 비교 요약
- [x] 다음 개선 과제 3개 정의

완료 기준
- Week2 종료 리포트 1개 작성

## Week 2 DoD
- [x] 경고 규칙 기반 탐지 경로 확보
- [x] 장애 재현 + 대응 사례 1건 확보
- [x] 다음 단계 개선 과제 확정
