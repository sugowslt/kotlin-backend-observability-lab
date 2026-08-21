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
		val traceId = normalizeTraceId(request.getHeader(TRACE_HEADER))
		val trafficType = normalizeTrafficType(request.getHeader(TRAFFIC_TYPE_HEADER))

		val startNanos = System.nanoTime()
		MDC.put(MDC_TRACE_KEY, traceId)
		MDC.put(MDC_TRAFFIC_TYPE_KEY, trafficType)
		response.setHeader(TRACE_HEADER, traceId)
		response.setHeader(TRAFFIC_TYPE_HEADER, trafficType)

		appLogger.info(
			"http.request.start method={} path={} traceId={} trafficType={} ",
			request.method,
			request.requestURI,
			traceId,
			trafficType,
		)

		try {
			filterChain.doFilter(request, response)
		} finally {
			val latencyMs = (System.nanoTime() - startNanos) / 1_000_000
			appLogger.info(
				"http.request.end method={} path={} status={} latencyMs={} traceId={} trafficType={}",
				request.method,
				request.requestURI,
				response.status,
				latencyMs,
				traceId,
				trafficType,
			)
			MDC.remove(MDC_TRACE_KEY)
			MDC.remove(MDC_TRAFFIC_TYPE_KEY)
		}
	}

	companion object {
		const val TRACE_HEADER = "X-Trace-Id"
		const val TRAFFIC_TYPE_HEADER = "X-Traffic-Type"
		const val DEFAULT_TRAFFIC_TYPE = "normal"
		const val DRILL_TRAFFIC_TYPE = "drill"
		const val MDC_TRACE_KEY = "traceId"
		const val MDC_TRAFFIC_TYPE_KEY = "trafficType"
		private const val MAX_TRACE_ID_LENGTH = 64
		private val VALID_TRACE_ID = Regex("[A-Za-z0-9._-]+")

		fun normalizeTrafficType(value: String?): String = when (value?.trim()?.lowercase()) {
			DRILL_TRAFFIC_TYPE -> DRILL_TRAFFIC_TYPE
			else -> DEFAULT_TRAFFIC_TYPE
		}

		fun normalizeTraceId(value: String?): String {
			val candidate = value?.trim()
			return candidate
				?.takeIf { it.length in 1..MAX_TRACE_ID_LENGTH && VALID_TRACE_ID.matches(it) }
				?: UUID.randomUUID().toString().replace("-", "").take(16)
		}
	}
}
