package com.CartorioService.CartorioService.controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import com.CartorioService.CartorioService.domain.Cartorio;
import com.CartorioService.CartorioService.repository.CartorioRepository;

@RestController
public class CartorioController {
	
	@Autowired
	private CartorioRepository cartorioRepository;
	
	@GetMapping(value = "/cartorio/{cartorioId}")
	public Cartorio findAllByCartorioId(@PathVariable int cartorioId) {
		return cartorioRepository.findAllByCartorioId(cartorioId);
	}
	
	@CrossOrigin(origins = "http://localhost:4200/putatualizar")
	@PutMapping(value = "/cartorio/alterar/{cartorioId}")
	public Cartorio alterar(@RequestBody Cartorio cartorioAlterado, @PathVariable int cartorioId) {
		Cartorio cart = findAllByCartorioId(cartorioId);
		cart.setNome(cartorioAlterado.getNome());
		cart.setObservacao(cartorioAlterado.getObservacao());
		cart.setSituacao_cartorio(cartorioAlterado.getSituacao_cartorio());
		cart.setLista_atribuicoes(cartorioAlterado.getLista_atribuicoes());
		cartorioRepository.save(cart);
		return cart;
	}
	
	@GetMapping(value = "/cartorio")
	public List<Cartorio> findAll() {
		return cartorioRepository.findAll();
	}
	
	@PostMapping(value = "/cartorio/cartorioAdd")
	public @ResponseBody Cartorio cartorioAdd(@RequestBody Cartorio novoCartorio) {
	    return cartorioRepository.save(novoCartorio);
	}
	
	@CrossOrigin(origins = "http://localhost:4200/delete")
	@DeleteMapping(value = "/cartorio/delete/{cartorioId}")
	public String deleteById(@PathVariable("cartorioId") int id) {
		cartorioRepository.deleteById(id);
		return "Registro " + id + " excluído com sucesso.";
	}
	
	@GetMapping(value = "/cartorio/verificarExistencia/{nome}")
	public @ResponseBody String findCartorioComSituacaoCadastrada(@PathVariable("nome") String verificarNome) {
		String idCartorio;
		if (cartorioRepository.findCartorioComSituacaoCadastrada(verificarNome) == null) {
			idCartorio = "0";
			System.out.println(idCartorio);
			return idCartorio;
		}
		idCartorio = cartorioRepository.findCartorioComSituacaoCadastrada(verificarNome);
		System.out.println(idCartorio);
	    return idCartorio;
	}
	
	@CrossOrigin(origins = "http://localhost:6161/situacoes.html")
	@PutMapping(value = "/cartorio/atualizarCartorio/{nomeSituacao}")
	public Cartorio alterarNomeSituacaoTabelaCartorios(@PathVariable String nomeNovo, @PathVariable String nomeAntigo) {
		Cartorio cart = alterarNomeSituacaoTabelaCartorios(nomeNovo, nomeAntigo);
		return cart;
	}
}
