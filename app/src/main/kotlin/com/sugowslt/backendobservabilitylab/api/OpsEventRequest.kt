package com.sugowslt.backendobservabilitylab.api

import jakarta.validation.constraints.NotBlank

data class OpsEventRequest(
	@field:NotBlank(message = "eventType must not be blank")
	val eventType: String,
	@field:NotBlank(message = "payload must not be blank")
	val payload: String,
)
