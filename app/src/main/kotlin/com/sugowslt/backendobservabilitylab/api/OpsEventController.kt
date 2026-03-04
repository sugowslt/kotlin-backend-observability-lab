package com.sugowslt.backendobservabilitylab.api

import jakarta.validation.Valid
import org.slf4j.LoggerFactory
import org.slf4j.MDC
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/v1/ops/events")
class OpsEventController {

	private val logger = LoggerFactory.getLogger(OpsEventController::class.java)

	@PostMapping
	fun publish(@Valid @RequestBody request: OpsEventRequest): Map<String, Any> {
		val traceId = MDC.get("traceId") ?: "unknown"

		if (request.delayMs > 0) {
			Thread.sleep(request.delayMs)
		}

		if (request.forceError) {
			throw IllegalStateException("forced error for drill")
		}

		logger.info(
			"ops.event.accepted eventType={} payloadSize={} delayMs={} traceId={}",
			request.eventType,
			request.payload.length,
			request.delayMs,
			traceId,
		)

		return mapOf(
			"status" to "accepted",
			"eventType" to request.eventType,
			"traceId" to traceId,
		)
	}
}
