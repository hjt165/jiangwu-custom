package com.jiangwu.config;

import com.jiangwu.interceptor.AuthInterceptor;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.*;

/**
 * Web 配置：CORS + 拦截器
 */
@Configuration
@RequiredArgsConstructor
public class WebConfig implements WebMvcConfigurer {

    private final AuthInterceptor authInterceptor;

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOriginPatterns("*")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(authInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns(
                        // 用户认证
                        "/user/register",
                        "/user/login",
                        // 作品浏览（无需认证）
                        "/product/list",
                        "/product/search",
                        "/product/featured",
                        "/product/*/id",
                        // 手作人浏览（无需认证）
                        "/artisan/list",
                        "/artisan/search",
                        // Swagger
                        "/v3/api-docs/**",
                        "/swagger-ui/**",
                        "/swagger-ui.html",
                        // WebSocket
                        "/ws/**"
                );
    }
}
