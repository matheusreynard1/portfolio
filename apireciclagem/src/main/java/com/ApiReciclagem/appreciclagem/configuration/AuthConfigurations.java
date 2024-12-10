package com.ApiReciclagem.appreciclagem.configuration;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

//ACESSAR O SWAGGER = http://localhost:6565/swagger-ui.html

@Configuration
@EnableWebSecurity
public class AuthConfigurations {

	@Autowired
	private FilterToken filter;

	@Bean
	// FILTROS DA AUTENTICAÇÃO
	public SecurityFilterChain securityFilterChain(HttpSecurity httpSecurity) throws Exception {
		return httpSecurity.csrf(csrf -> csrf.disable())
				.sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
				.addFilterBefore(filter, UsernamePasswordAuthenticationFilter.class)
				.authorizeHttpRequests(
						authorize -> authorize.antMatchers("/**.html", "/v2/api-docs", "/v3/api-docs/**").permitAll()
						.antMatchers("/swagger-resouces/**").permitAll()
			            .antMatchers("/configuration/**").permitAll()
			            .antMatchers("/configuration/security").permitAll()
			            .antMatchers("/webjars/**").permitAll()
			            .antMatchers("/v2/**").permitAll()
			            .antMatchers("/swagger-ui.html").permitAll()
			            .antMatchers("/swagger-ui/index.html").permitAll()
			            .antMatchers("/swagger-ui/**").permitAll()
			            .antMatchers(HttpMethod.POST, "/empresa/empresaAdd", "/empresa/login").permitAll()
			            .antMatchers(HttpMethod.GET, "/empresa/nomeExistente/{empresaNome}").permitAll()
			            .antMatchers(HttpMethod.GET, "/empresa/nomeRepetido/{empresaNome}/{empresaId}").permitAll()
			            .antMatchers(HttpMethod.PUT, "/empresa/alterar/{empresaId}").permitAll()
			            .anyRequest().authenticated())
				.build();
	}

	@Bean
	// GERAR SENHA CRIPTOGRAFADA
	public PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder();
	}

	// RETORNAR O AUTHENTICATION MANAGER
	@Bean
	public AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration)
			throws Exception {
		return authenticationConfiguration.getAuthenticationManager();
	}
}
