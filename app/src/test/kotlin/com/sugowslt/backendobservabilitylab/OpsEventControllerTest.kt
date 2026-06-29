package com.sugowslt.backendobservabilitylab

import com.sugowslt.backendobservabilitylab.api.OpsEventRequest
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.post
import kotlin.test.assertEquals
import kotlin.test.assertTrue

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
        }.andExpect {
            status { isOk() }
            content { contentType(MediaType.APPLICATION_JSON) }
        }
    }
}
