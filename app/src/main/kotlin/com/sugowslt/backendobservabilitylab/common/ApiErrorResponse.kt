package com.sugowslt.backendobservabilitylab.common

import java.time.Instant

data class ApiErrorResponse(
	val timestamp: String = Instant.now().toString(),
	val status: Int,
	val errorCode: String,
	val message: String,
	val path: String,
	val traceId: String,
)
