package com.ApiReciclagem.appreciclagem.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.ApiReciclagem.appreciclagem.repository.EmpresaReciclagemRepository;

@Service
public class AuthenticationService implements UserDetailsService {
	
	@Autowired
	private EmpresaReciclagemRepository empresaRepository;

	@Override
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		return empresaRepository.findByNome(username);
	}
	
}
