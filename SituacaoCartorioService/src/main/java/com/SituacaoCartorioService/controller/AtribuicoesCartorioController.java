package com.SituacaoCartorioService.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import com.SituacaoCartorioService.domain.AtribuicoesCartorio;
import com.SituacaoCartorioService.repository.AtribuicoesCartorioRepository;

@RestController
public class AtribuicoesCartorioController {
	
	@Autowired
	AtribuicoesCartorioRepository atribuicoesCartorioRepository;
	
	@PutMapping(value = "/atribuicoesCartorio/alterar/{atribuicoesCartorioId}")
	public AtribuicoesCartorio alterar(@RequestBody AtribuicoesCartorio atribuicaoAlterada, @PathVariable int atribuicoesCartorioId) {
		AtribuicoesCartorio atri = findAllById(atribuicoesCartorioId);
		atri.setNome(atribuicaoAlterada.getNome());
		atri.setTipo(atribuicaoAlterada.getTipo());
		atribuicoesCartorioRepository.save(atri);
		return atri;
	}
	
	@GetMapping(value = "/atribuicoesCartorio")
	public <List>Iterable<AtribuicoesCartorio> findAll() {
		return atribuicoesCartorioRepository.findAll();
	}
	
	@PostMapping(value = "/atribuicoesCartorio/atribuicoesCartorioAdd")
	public @ResponseBody AtribuicoesCartorio atribuicoesCartorioAdd(@RequestBody AtribuicoesCartorio novaAtribuicaoCartorio) {
	    return atribuicoesCartorioRepository.save(novaAtribuicaoCartorio);
	}
	
	@DeleteMapping(value = "/atribuicoesCartorio/delete/{atribuicoesCartorioId}")
	public String deleteById(@PathVariable("atribuicoesCartorioId") int atribuicoesCartorioId) {
		atribuicoesCartorioRepository.deleteById(atribuicoesCartorioId);
		return "Registro " + atribuicoesCartorioId + " excluído com sucesso.";
	}
	
	@GetMapping(value = "/atribuicoesCartorio/{atribuicoesCartorioId}")
	AtribuicoesCartorio findAllById(@PathVariable int atribuicoesCartorioId) {
		return atribuicoesCartorioRepository.findAllById(atribuicoesCartorioId);
	}

}
