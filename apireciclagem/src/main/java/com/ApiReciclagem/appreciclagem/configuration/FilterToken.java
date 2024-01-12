package com.ApiReciclagem.appreciclagem.configuration;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import com.ApiReciclagem.appreciclagem.repository.EmpresaReciclagemRepository;
import com.ApiReciclagem.appreciclagem.service.TokenService;

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
