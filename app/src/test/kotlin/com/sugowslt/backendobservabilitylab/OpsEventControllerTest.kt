package com.sugowslt.backendobservabilitylab

import org.hamcrest.Matchers.containsString
import org.hamcrest.Matchers.not
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.get
import org.springframework.test.web.servlet.post
import kotlin.test.assertNotEquals

@SpringBootTest
@AutoConfigureMockMvc
class OpsEventControllerTest {

    @Autowired
    private lateinit var mockMvc: MockMvc

    @Test
    fun `publish 정상 요청시 accepted 응답`() {
        mockMvc.post("/api/v1/ops/events") {
            contentType = MediaType.APPLICATION_JSON
            content = """{"eventType":"test","payload":"{}","delayMs":0,"forceError":false}"""
            accept = MediaType.APPLICATION_JSON
            header("X-Trace-Id", "trace-test-1")
        }.andExpect {
            status { isOk() }
            content { contentType(MediaType.APPLICATION_JSON) }
            header { string("X-Trace-Id", "trace-test-1") }
            header { string("X-Traffic-Type", "normal") }
            jsonPath("$.status") { value("accepted") }
            jsonPath("$.traceId") { value("trace-test-1") }
        }
    }

    @Test
    fun `forceError 요청은 500 응답과 추적 ID를 반환한다`() {
        mockMvc.post("/api/v1/ops/events") {
            contentType = MediaType.APPLICATION_JSON
            content = """{"eventType":"test","payload":"{}","forceError":true}"""
            header("X-Trace-Id", "trace-error-1")
            header("X-Traffic-Type", "drill")
        }.andExpect {
            status { isInternalServerError() }
            header { string("X-Trace-Id", "trace-error-1") }
            header { string("X-Traffic-Type", "drill") }
            jsonPath("$.errorCode") { value("INTERNAL_SERVER_ERROR") }
            jsonPath("$.traceId") { value("trace-error-1") }
        }
    }

    @Test
    fun `검증 실패 요청은 400 응답을 반환한다`() {
        mockMvc.post("/api/v1/ops/events") {
            contentType = MediaType.APPLICATION_JSON
            content = """{"eventType":"","payload":"{}"}"""
            header("X-Trace-Id", "trace-validation-1")
        }.andExpect {
            status { isBadRequest() }
            jsonPath("$.errorCode") { value("VALIDATION_FAILED") }
            jsonPath("$.traceId") { value("trace-validation-1") }
        }
    }

    @Test
    fun `허용되지 않은 트래픽 유형은 normal로 정규화한다`() {
        mockMvc.post("/api/v1/ops/events") {
            contentType = MediaType.APPLICATION_JSON
            content = """{"eventType":"test","payload":"{}"}"""
            header("X-Traffic-Type", "customer-12345")
        }.andExpect {
            status { isOk() }
            header { string("X-Traffic-Type", "normal") }
        }
    }

    @Test
    fun `유효하지 않은 추적 ID는 안전한 값으로 교체한다`() {
        val result = mockMvc.post("/api/v1/ops/events") {
            contentType = MediaType.APPLICATION_JSON
            content = """{"eventType":"test","payload":"{}"}"""
            header("X-Trace-Id", "trace id with spaces")
        }.andExpect {
            status { isOk() }
            header { exists("X-Trace-Id") }
        }.andReturn()

        assertNotEquals("trace id with spaces", result.response.getHeader("X-Trace-Id"))
    }

    @Test
    fun `Prometheus에 요청 히스토그램과 제한된 트래픽 유형을 노출한다`() {
        mockMvc.post("/api/v1/ops/events") {
            contentType = MediaType.APPLICATION_JSON
            content = """{"eventType":"metrics-test","payload":"{}"}"""
            header("X-Traffic-Type", "unbounded-customer-id")
        }.andExpect {
            status { isOk() }
        }

        mockMvc.get("/actuator/prometheus").andExpect {
            status { isOk() }
            content { string(containsString("http_server_requests_seconds_bucket")) }
            content { string(containsString("traffic_type=\"normal\"")) }
            content { string(not(containsString("unbounded-customer-id"))) }
        }
    }
}
