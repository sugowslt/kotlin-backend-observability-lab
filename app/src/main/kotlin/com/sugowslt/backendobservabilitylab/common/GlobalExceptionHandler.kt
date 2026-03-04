package com.sugowslt.backendobservabilitylab.common

import jakarta.servlet.http.HttpServletRequest
import org.slf4j.LoggerFactory
import org.slf4j.MDC
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.MethodArgumentNotValidException
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice

@RestControllerAdvice
class GlobalExceptionHandler {

	private val logger = LoggerFactory.getLogger(GlobalExceptionHandler::class.java)

	@ExceptionHandler(MethodArgumentNotValidException::class)
	fun handleValidationException(
		exception: MethodArgumentNotValidException,
		request: HttpServletRequest,
	): ResponseEntity<ApiErrorResponse> {
		val traceId = MDC.get("traceId") ?: "unknown"
		val message = exception.bindingResult.fieldErrors.firstOrNull()?.defaultMessage
			?: "validation failed"
		val errorCode = "VALIDATION_FAILED"

		logger.error(
			"http.request.error errorCode={} status={} path={} traceId={} reason={}",
			errorCode,
			HttpStatus.BAD_REQUEST.value(),
			request.requestURI,
			traceId,
			message,
		)

		return ResponseEntity
			.status(HttpStatus.BAD_REQUEST)
			.body(
				ApiErrorResponse(
					status = HttpStatus.BAD_REQUEST.value(),
					errorCode = errorCode,
					message = message,
					path = request.requestURI,
					traceId = traceId,
				),
			)
	}

	@ExceptionHandler(Exception::class)
	fun handleGenericException(
		exception: Exception,
		request: HttpServletRequest,
	): ResponseEntity<ApiErrorResponse> {
		val traceId = MDC.get("traceId") ?: "unknown"
		val errorCode = "INTERNAL_SERVER_ERROR"

		logger.error(
			"http.request.error errorCode={} status={} path={} traceId={} reason={}",
			errorCode,
			HttpStatus.INTERNAL_SERVER_ERROR.value(),
			request.requestURI,
			traceId,
			exception.message,
			exception,
		)

		return ResponseEntity
			.status(HttpStatus.INTERNAL_SERVER_ERROR)
			.body(
				ApiErrorResponse(
					status = HttpStatus.INTERNAL_SERVER_ERROR.value(),
					errorCode = errorCode,
					message = "unexpected server error",
					path = request.requestURI,
					traceId = traceId,
				),
			)
	}
}
