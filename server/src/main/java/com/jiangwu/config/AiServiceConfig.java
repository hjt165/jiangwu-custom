package com.jiangwu.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.ExchangeStrategies;
import org.springframework.web.reactive.function.client.WebClient;

/**
 * AI 服务 WebClient 配置
 */
@Configuration
public class AiServiceConfig {

    @Value("${ai.service.base-url:http://localhost:8001/api/ai}")
    private String aiServiceBaseUrl;

    @Value("${ai.service.timeout:30000}")
    private int timeout;

    @Value("${ai.service.connect-timeout:5000}")
    private int connectTimeout;

    @Bean(name = "aiServiceWebClient")
    public WebClient aiServiceWebClient() {
        ExchangeStrategies strategies = ExchangeStrategies.builder()
                .codecs(configurer -> configurer.defaultCodecs().maxInMemorySize(10 * 1024 * 1024))
                .build();

        return WebClient.builder()
                .baseUrl(aiServiceBaseUrl)
                .exchangeStrategies(strategies)
                .build();
    }
}
