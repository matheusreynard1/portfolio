package com.ApiReciclagem.appreciclagem;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.context.annotation.Bean;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@EnableDiscoveryClient
@SpringBootApplication(exclude = {SecurityAutoConfiguration.class })
public class AppreciclagemApplication {

	public static void main(String[] args) {
		SpringApplication.run(AppreciclagemApplication.class, args);
	}

	@Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/**") // Mapeie apenas para a rota que você deseja
                    .allowedOrigins("*"); // Permite todas as origens (não recomendado para produção)
            }
        };
    }
	
}
