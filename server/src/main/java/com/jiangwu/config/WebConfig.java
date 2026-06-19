package com.jiangwu.config;

import com.jiangwu.interceptor.AuthInterceptor;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.*;

import java.util.List;

/**
 * Web 配置：CORS + 拦截器
 */
@Configuration
@RequiredArgsConstructor
public class WebConfig implements WebMvcConfigurer {

    private final AuthInterceptor authInterceptor;

    @Value("${cors.allowed-origins:http://localhost:3000,http://localhost:5173}")
    private String allowedOrigins;

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        // 从配置读取允许的域名，不再使用通配符 *
        List<String> origins = List.of(allowedOrigins.split(","));
        registry.addMapping("/**")
                .allowedOrigins(origins.toArray(new String[0]))
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
                        "/user/send-code",
                        "/user/reset-password",
                        // 管理员认证
                        "/admin/login",
                        // 作品浏览（无需认证）
                        "/product/list",
                        "/product/search",
                        "/product/featured",
                        "/product/detail/**",
                        // 手作人浏览（无需认证）
                        "/artisan/list",
                        "/artisan/search",
                        "/artisan/detail/**",
                        // 材质浏览（无需认证）
                        "/material/list",
                        "/material/category/**",
                        // Swagger
                        "/v3/api-docs/**",
                        "/swagger-ui/**",
                        "/swagger-ui.html",
                        // WebSocket
                        "/ws/**"
                );
    }
}
