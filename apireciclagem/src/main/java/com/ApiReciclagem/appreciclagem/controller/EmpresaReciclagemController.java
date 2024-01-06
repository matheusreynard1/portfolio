package com.ApiReciclagem.appreciclagem.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.ApiReciclagem.appreciclagem.domain.EmpresaReciclagem;
import com.ApiReciclagem.appreciclagem.domain.LoginDTO;
import com.ApiReciclagem.appreciclagem.repository.EmpresaReciclagemRepository;
import com.ApiReciclagem.appreciclagem.service.TokenService;

@RestController
public class EmpresaReciclagemController {
	
	@Autowired
	private EmpresaReciclagemRepository empresaRepository;
	
	@Autowired
	private TokenService tokenService;
	
	@PostMapping(value = "/empresa/login")
	public String realizarLogin(@RequestBody LoginDTO loginDTO) {
		BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
		EmpresaReciclagem usuario = new EmpresaReciclagem();
		
		usuario.setNome(loginDTO.login());
		usuario.setSenha(loginDTO.senha());
		
		String senhaArmazenada = empresaRepository.getSenhaByNome(loginDTO.login());
		
		if (encoder.matches(loginDTO.senha(), senhaArmazenada)) {
			System.out.println("token: " + senhaArmazenada);
			return tokenService.gerarToken(usuario);
		} else {
			return "Credenciais inválidas.";
		}
		
	}
	
	@CrossOrigin(origins = "http://192.168.15.28:8081")
	@PostMapping(value = "/empresa/empresaAdd")
	public @ResponseBody EmpresaReciclagem empresaAdd(@RequestBody EmpresaReciclagem novaEmpresa) {
		String senhaCriptografada = new BCryptPasswordEncoder().encode(novaEmpresa.getSenha());
		novaEmpresa.setSenha(senhaCriptografada);
	    return empresaRepository.save(novaEmpresa);
	}
	
	@GetMapping(value = "/empresa/{empresaId}")
	public EmpresaReciclagem findAllByEmpresaId(@PathVariable int empresaId) {
		return empresaRepository.findAllByEmpresaId(empresaId);
	}
	
	@GetMapping(value = "/empresa/buscarNome/{empresaNome}")
	public List<EmpresaReciclagem> findAllByEmpresaNome(@PathVariable String empresaNome) {
		return empresaRepository.findAllByEmpresaNome(empresaNome);
	}
	
	@GetMapping(value = "/empresa/nomeExistente/{empresaNome}")
	public List<EmpresaReciclagem> findNome(@PathVariable String empresaNome) {
		return empresaRepository.findNome(empresaNome);
	}
	
	@CrossOrigin(origins = "http://192.168.15.28:8081")
	@GetMapping(value = "/empresa")
	public List<EmpresaReciclagem> findAll() {
		System.out.println("ENTROU FINDALL");
		return empresaRepository.findAll();
	}
	
	//@CrossOrigin(origins = "http://localhost:4200/delete")
	@DeleteMapping(value = "/empresa/delete/{empresaId}")
	public String deleteById(@PathVariable("empresaId") int id) {
		empresaRepository.deleteById(id);
		return "Registro " + id + " excluído com sucesso.";
	}
	
	
	
}
