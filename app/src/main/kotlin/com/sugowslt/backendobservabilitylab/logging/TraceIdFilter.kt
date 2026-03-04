package com.sugowslt.backendobservabilitylab.logging

import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.slf4j.LoggerFactory
import org.slf4j.MDC
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter
import java.util.UUID

@Component
class TraceIdFilter : OncePerRequestFilter() {

	private val appLogger = LoggerFactory.getLogger(TraceIdFilter::class.java)

	override fun doFilterInternal(
		request: HttpServletRequest,
		response: HttpServletResponse,
		filterChain: FilterChain,
	) {
		val traceId = request.getHeader(TRACE_HEADER)
			?.takeIf { it.isNotBlank() }
			?: UUID.randomUUID().toString().replace("-", "").take(16)

		val startNanos = System.nanoTime()
		MDC.put(MDC_TRACE_KEY, traceId)
		response.setHeader(TRACE_HEADER, traceId)

		appLogger.info(
			"http.request.start method={} path={} traceId={}",
			request.method,
			request.requestURI,
			traceId,
		)

		try {
			filterChain.doFilter(request, response)
		} finally {
			val latencyMs = (System.nanoTime() - startNanos) / 1_000_000
			appLogger.info(
				"http.request.end method={} path={} status={} latencyMs={} traceId={}",
				request.method,
				request.requestURI,
				response.status,
				latencyMs,
				traceId,
			)
			MDC.remove(MDC_TRACE_KEY)
		}
	}

	companion object {
		const val TRACE_HEADER = "X-Trace-Id"
		const val MDC_TRACE_KEY = "traceId"
	}
}
