# project3-backend-observability-lab

운영/관측성 역량 증명을 위한 Kotlin Spring Boot 기반 실습 프로젝트입니다.

## 1) 프로젝트 목표
- 운영 관점 핵심 지표(SLI) 정의 및 측정 경로 확보
- 구조화 로그 + Trace ID 기반 추적 가능 상태 구축
- 메트릭 수집/시각화/장애 대응 문서까지 연결된 운영 루프 구현

## 2) 현재 상태 (Week 1 시작)
- ISSUE-1 완료: 운영 목표/지표 정의
- 다음 이슈: ISSUE-2 (프로젝트/환경 초기화)

관련 문서
- `activity-plan.md`
- `week1-issues.md`
- `operations-sli-goals.md`

## 3) Week 1 실행 순서
1. 운영 목표/지표 정의 (`operations-sli-goals.md`)
2. Spring Boot + Actuator/Micrometer + Docker Compose 초기화
3. 구조화 로그 + Trace ID/MDC 적용
4. Prometheus/Grafana 수집 경로 구성
5. CI 기본 파이프라인 구축

## 4) Week 1 DoD
- 운영 지표 수집 경로 확보
- 로그 추적 가능 상태 확보
- 장애 대응 문서 템플릿 생성
