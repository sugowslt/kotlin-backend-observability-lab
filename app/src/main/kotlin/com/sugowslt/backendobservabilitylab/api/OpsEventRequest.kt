package com.sugowslt.backendobservabilitylab.api

import jakarta.validation.constraints.Max
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.PositiveOrZero

data class OpsEventRequest(
    @field:NotBlank(message = "eventType must not be blank")
    val eventType: String,

    @field:NotBlank(message = "payload must not be blank")
    val payload: String,

    @field:PositiveOrZero(message = "delayMs must be >= 0")
    @field:Max(value = 30_000, message = "delayMs must be <= 30000")
    val delayMs: Long = 0,

    val forceError: Boolean = false,
)
