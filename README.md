# project3-backend-observability-lab

운영 관측성 관점으로 백엔드를 점검해 보기 위해 만든 실습 프로젝트입니다.

단순히 대시보드 화면을 띄우는 데서 멈추지 않고,
traceId, 로그, 메트릭, alert, 드릴, 오탐률 점검까지 한 번에 묶어서 다뤘습니다.

## 핵심 포인트
- `X-Trace-Id` 기반 요청 추적
- 구조화 로그 + 표준 에러 응답
- Prometheus 수집 + Grafana 시각화
- alert rule 설정 및 반복 드릴
- `traffic_type` 라벨로 drill/normal 트래픽 분리
- 정상 구간 false positive 점검

## 기술 스택
- Kotlin + Spring Boot
- Spring Actuator, Micrometer
- Prometheus, Grafana
- Docker Compose
- GitHub Actions(CI)

## 빠른 실행

### 앱 실행
```powershell
cd app
.\gradlew.bat test
.\gradlew.bat bootRun
```

확인
- Health: `http://localhost:8080/actuator/health`
- Metrics: `http://localhost:8080/actuator/prometheus`

### 관측 스택 실행
```powershell
docker compose up -d
```

확인
- Prometheus: `http://localhost:19090`
- Grafana: `http://localhost:13000` (`admin/admin`)

## 시연 흐름
1. `POST /api/v1/ops/events` 호출
2. 응답 `traceId` 확인
3. 로그(`http.request.start`, `http.request.end`)와 연결 확인
4. Grafana에서 지표 변화 확인
5. Prometheus에서 targets/rules/query 확인

## 드릴과 운영 리포트

### Week2
- alert 기본 세트 구성
- timeout / graceful shutdown 적용
- 드릴 1차 실행
- 운영 리포트 작성

실측 예시
- latency-spike TTD: `5.05s`
- error-spike TTD: `25.02s`

### Week3
- alert 민감도 튜닝
- 반복 드릴 자동화
- 운영 리포트 작성

### Week4
- cooldown + baseline recovery 자동화
- 보정 드릴 3회 본측정
- 최종 운영 프로필 정리

실측 요약
- Latency median: `10.00s`
- Error median: `15.02s`

## 운영 안정화 보강
- `X-Traffic-Type` 기반 `traffic_type` 라벨 분리
- alert는 `traffic_type=normal` 기준으로만 평가
- 정상 구간 false positive 점검 결과: `0건`

이 부분은 실제로 꽤 중요했습니다. 실험 트래픽이 운영 지표를 오염시키면, 알림 튜닝 자체가 의미 없어지기 때문입니다.

## 주요 트러블슈팅
- Prometheus rules 미노출
  - 원인: `alerts.yml` 마운트 누락
  - 해결: compose 볼륨 수정
- histogram 미노출로 p95 query 실패
  - 원인: summary 중심 메트릭
  - 해결: `http_server_requests_seconds_max` 기반으로 전환
- 반복 드릴에서 TTD 0초 왜곡
  - 원인: 이전 run 윈도우 잔존
  - 해결: cooldown + baseline recovery 체크 추가
- drill 트래픽이 운영 경보 오염
  - 해결: `X-Traffic-Type`, `traffic_type` 라벨 도입

## 주요 파일
- `prometheus/prometheus.yml`
- `prometheus/alerts.yml`
- `grafana-dashboard-draft.json`
- `scripts/run-week2-drill.ps1`
- `scripts/run-week3-drill-series.ps1`
- `normal-traffic-false-positive-result.json`

## 관련 문서
- `operations-sli-goals.md`
- `incident-response-template.md`
- `stability-settings-week2.md`
- `week2-operations-report.md`
- `week3-alert-tuning-notes.md`
- `week3-operations-report.md`
- `week4-operations-report.md`
- `normal-traffic-false-positive-report.md`

## 현재 상태
- 구현/드릴/튜닝/리포트/오탐 점검까지 완료
- 포트폴리오 시연 가능한 상태

## 라이선스
MIT License. 자세한 내용은 `LICENSE` 파일을 참고하세요.

## 공개 공지

이 저장소는 포트폴리오 공개를 목적으로 준비한 코드입니다. 민감정보는 포함하지 않았습니다.


## 공개 버전 안내

이 프로젝트는 포트폴리오 공개를 목적으로 정리했습니다.
민감정보(비밀번호, API 키, 토큰)는 포함하지 않았습니다.
실행은 로컬 환경에서만 권장합니다.
