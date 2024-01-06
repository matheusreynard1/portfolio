package com.ApiReciclagem.appreciclagem.configuration;

import java.io.IOException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import com.ApiReciclagem.appreciclagem.repository.EmpresaReciclagemRepository;
import com.ApiReciclagem.appreciclagem.service.TokenService;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

// FILTRO DO TOKEN PARA O AUTHCONFIGURATIONS
@Component
public class FilterToken implements Filter {

	@Autowired
	private TokenService tokenService;
	
	@Autowired
	private EmpresaReciclagemRepository empresaRepository;
	
	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
			throws IOException, ServletException {
		String token;
		var httpRequest = (HttpServletRequest) request;
		var authorizationHeader = httpRequest.getHeader("Authorization");
		
		if (authorizationHeader != null) {
			token = authorizationHeader.replace("Bearer ", "");
			
			var subject = this.tokenService.getSubject(token);
			
			var usuario = this.empresaRepository.findByNome(subject.toString());
			
			var authentication = new UsernamePasswordAuthenticationToken(usuario, null, usuario.getAuthorities());
			
			SecurityContextHolder.getContext().setAuthentication(authentication);
		}
		
		// Chame o próximo filtro na cadeia
		chain.doFilter(request, response);
	}
}
