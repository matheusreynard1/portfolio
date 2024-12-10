package com.ApiReciclagem.appreciclagem.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
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
			return tokenService.gerarToken(usuario);
		} else {
			return "Credenciais inválidas.";
		}

	}
	
	@PutMapping(value = "/empresa/alterar/{empresaId}")
	public EmpresaReciclagem alterar( @PathVariable int empresaId, @RequestBody EmpresaReciclagem empresaAlterada) {
		EmpresaReciclagem empresa = findAllByEmpresaId(empresaId);
		empresa.setNome(empresaAlterada.getNome());
		empresa.setSenha(new BCryptPasswordEncoder().encode(empresaAlterada.getSenha()));
		empresa.setEmail(empresaAlterada.getEmail());
		empresa.setTelefone(empresaAlterada.getTelefone());
		empresa.setEndereco(empresaAlterada.getEndereco());
		empresaRepository.save(empresa);
		return empresa;
	}
	
	/*@GetMapping(value = "/empresa/findId/{empresaNome}")
	public int findId(@PathVariable String empresaNome) {
		return empresaRepository.findId(empresaNome);
	}*/
	
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
	public EmpresaReciclagem findNome(@PathVariable String empresaNome) {
		return empresaRepository.findByNome(empresaNome);
	}
	
	@GetMapping(value = "/empresa/nomeRepetido/{empresaNome}/{empresaId}")
	public int findNomeRepetido(@PathVariable String empresaNome, @PathVariable String empresaId) {
		return empresaRepository.findNomeRepetido(empresaNome, empresaId);
	}
	

	@GetMapping(value = "/empresa")
	public List<EmpresaReciclagem> findAll() {
		return empresaRepository.findAll();
	}

	@DeleteMapping(value = "/empresa/delete/{empresaId}")
	public String deleteById(@PathVariable("empresaId") int id) {
		empresaRepository.deleteById(id);
		return "Registro " + id + " excluído com sucesso.";
	}
	
	/*@GetMapping(value = "/empresa/alterarSenha/{login}/{senha}")
	public EmpresaReciclagem alterarSenha(@PathVariable String login, @PathVariable String senha) {
		BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
		EmpresaReciclagem usuario = new EmpresaReciclagem();
		String senhaArmazenada = empresaRepository.getSenhaByNome(login);
		usuario = (EmpresaReciclagem) empresaRepository.getUsuarioByLoginSenha(login, senha);

		// Não houve alteração na senha
		if (encoder.matches(senha, senhaArmazenada)) {
			System.out.println("senha: " + senha + " senha armazenada: " + senhaArmazenada);
			return null;
		} else {
			// Houve alteração na senha
			String senhaCriptografada = new BCryptPasswordEncoder().encode(senha);
			if (usuario != null)
				usuario.setSenha(senhaCriptografada);
			else
				usuario = new EmpresaReciclagem();
			return usuario;
		}
	}*/

}
