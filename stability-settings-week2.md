# Stability Settings (Week2 ISSUE-2)

기준일: 2026-03-05

## 1) 설정 목적
- 트래픽 급증/종료 시점에서 요청 손실을 줄이고, 과도한 대기 요청을 제어한다.

## 2) 적용 설정

### Graceful Shutdown
- `server.shutdown=graceful`
- `spring.lifecycle.timeout-per-shutdown-phase=20s`

의도
- 종료 신호 수신 시 진행 중인 요청을 최대한 정상 종료할 시간을 확보한다.

### Timeout 기본값
- `spring.mvc.async.request-timeout=5s`
- `server.tomcat.connection-timeout=5s`

의도
- 비정상 장기 대기 요청을 빠르게 정리해 스레드/연결 적체를 줄인다.

## 3) 운영 환경 변수 오버라이드
- `SHUTDOWN_PHASE_TIMEOUT` (기본: `20s`)
- `MVC_ASYNC_TIMEOUT` (기본: `5s`)
- `TOMCAT_CONNECTION_TIMEOUT` (기본: `5s`)

## 4) 점검 시나리오
1. 앱 실행 후 `/actuator/health` 정상(`UP`) 확인
2. 장기 요청 또는 지연 요청 상황에서 timeout 정책 동작 여부 확인
3. 종료 시그널 후 종료 지연 시간(최대 20초 내) 관찰

## 5) 결론
- Week2 ISSUE-2 기준으로 안정성 기본값(Timeout/Graceful Shutdown) 적용 완료.
