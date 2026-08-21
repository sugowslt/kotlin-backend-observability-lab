package com.sugowslt.backendobservabilitylab.config

import com.sugowslt.backendobservabilitylab.logging.TraceIdFilter
import io.micrometer.common.KeyValue
import io.micrometer.common.KeyValues
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.server.observation.DefaultServerRequestObservationConvention
import org.springframework.http.server.observation.ServerRequestObservationContext

@Configuration
class TrafficTypeObservationConfig {

	@Bean
	fun serverRequestObservationConvention(): DefaultServerRequestObservationConvention =
		object : DefaultServerRequestObservationConvention() {
			override fun getLowCardinalityKeyValues(context: ServerRequestObservationContext): KeyValues {
				val trafficType = TraceIdFilter.normalizeTrafficType(
					context.carrier?.getHeader(TraceIdFilter.TRAFFIC_TYPE_HEADER),
				)

				return super.getLowCardinalityKeyValues(context)
					.and(KeyValue.of("traffic_type", trafficType))
			}
		}
}
