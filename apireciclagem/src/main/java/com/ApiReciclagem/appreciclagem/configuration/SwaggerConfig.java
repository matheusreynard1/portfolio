package com.ApiReciclagem.appreciclagem.configuration;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.ExternalDocumentation;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityScheme;

// ACESSAR O SWAGGER = http://localhost:6565/swagger-ui.html

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI empresasApi() {
        return new OpenAPI()
        .info(new Info().title("Reciclando S.A endpoints")
        .description("Endpoints do projeto Reciclando S.A")
        .version("v0.0.1"))
        .externalDocs(new ExternalDocumentation()
        .description("Github")
        .url("https://github.com/matheusreynard1"))
        .components(new Components()
          .addSecuritySchemes("bearer-key",
          new SecurityScheme().type(SecurityScheme.Type.HTTP).scheme("bearer").in(SecurityScheme.In.HEADER).bearerFormat("JWT")));
    }

}