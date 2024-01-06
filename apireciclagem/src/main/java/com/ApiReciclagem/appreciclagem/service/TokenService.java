package com.ApiReciclagem.appreciclagem.service;

import java.time.LocalDateTime;
import java.time.ZoneOffset;

import org.springframework.stereotype.Service;

import com.ApiReciclagem.appreciclagem.domain.EmpresaReciclagem;
import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;

@Service
public class TokenService {
	
	// GERAR O TOKEN
	public String gerarToken(EmpresaReciclagem usuario) {	
		return JWT.create()
				.withIssuer("AppReciclagem")
				.withSubject(usuario.getNome())
				.withClaim("empresaId", usuario.getEmpresaId())
			    .withExpiresAt(LocalDateTime.now().plusMinutes(10).toInstant(ZoneOffset.of("-03:00")))
			    .sign(Algorithm.HMAC256("secret"));
			    
	}

	// RECUPERAR O TOKEN
	public Object getSubject(String token) {
		return JWT.require(Algorithm.HMAC256("secret"))
				.withIssuer("AppReciclagem")
				.build().verify(token).getSubject();
	}

}
