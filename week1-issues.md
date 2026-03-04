# Project3 - Week 1 이슈

## 주간 목표
- 운영 관점 프로젝트의 기본 토대를 만들고 관측성(로그/메트릭) 기반을 구축한다.

## 이슈 목록 (체크리스트)

### ISSUE-1: 운영 목표/지표 정의
- [x] 서비스 SLI 3개 선정(응답시간/에러율/가용성)
- [x] 지표 수집 주기/방법 정의
- [x] 장애 시나리오 2개 정의

완료 기준
- 운영 목표 문서 1개 완료

산출물
- `operations-sli-goals.md`

---

### ISSUE-2: 프로젝트/환경 초기화
- [x] Kotlin Spring Boot 프로젝트 생성
- [x] Actuator/Micrometer 의존성 추가
- [x] Docker Compose 기본 구성

완료 기준
- `/actuator/health` 확인 가능

산출물
- `app/`
- `app/build.gradle.kts`
- `app/src/main/resources/application.yml`
- `docker-compose.yml`
- `prometheus/prometheus.yml`

---

### ISSUE-3: 구조화 로그 적용
- [x] 공통 로그 포맷(JSON 또는 key-value) 적용
- [x] Trace ID/MDC 연동
- [x] 에러 로그 표준 필드 정의

완료 기준
- 요청 1회당 추적 가능한 로그 출력 확인

산출물
- `app/src/main/kotlin/com/sugowslt/backendobservabilitylab/logging/TraceIdFilter.kt`
- `app/src/main/kotlin/com/sugowslt/backendobservabilitylab/common/GlobalExceptionHandler.kt`
- `app/src/main/kotlin/com/sugowslt/backendobservabilitylab/common/ApiErrorResponse.kt`
- `app/src/main/kotlin/com/sugowslt/backendobservabilitylab/api/OpsEventController.kt`
- `app/src/main/kotlin/com/sugowslt/backendobservabilitylab/api/OpsEventRequest.kt`

---

### ISSUE-4: 메트릭 노출 + 시각화 준비
- [ ] `/actuator/prometheus` 노출
- [ ] Prometheus scrape 설정
- [ ] Grafana 대시보드 초안 1개

완료 기준
- 기본 메트릭 수집 확인

---

### ISSUE-5: CI 기본 파이프라인
- [ ] GitHub Actions 워크플로우 생성
- [ ] 빌드 + 테스트 단계 추가
- [ ] 실패 시 로그 확인 경로 문서화

완료 기준
- CI 1회 실행 성공

## Week 1 DoD
- [ ] 운영 지표 수집 경로 확보
- [x] 로그 추적 가능 상태 확보
- [ ] 장애 대응 문서 템플릿 생성
