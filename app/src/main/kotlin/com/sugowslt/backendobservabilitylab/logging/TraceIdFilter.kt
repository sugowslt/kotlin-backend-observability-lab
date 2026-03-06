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
		val trafficType = request.getHeader(TRAFFIC_TYPE_HEADER)
			?.takeIf { it.isNotBlank() }
			?: DEFAULT_TRAFFIC_TYPE

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
		const val MDC_TRACE_KEY = "traceId"
		const val MDC_TRAFFIC_TYPE_KEY = "trafficType"
	}
}
