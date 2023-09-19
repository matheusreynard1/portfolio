package com.AtribuicoesCartorioService.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.AtribuicoesCartorioService.domain.AtribuicoesCartorio;
import com.AtribuicoesCartorioService.repository.AtribuicoesCartorioRepository;

@RestController
public class AtribuicoesCartorioController {
	
	@Autowired
	AtribuicoesCartorioRepository atribuicoesCartorioRepository;
	
	@GetMapping(value = "/atribuicoesCartorio/{atribuicoesCartorioId}")
	public AtribuicoesCartorio findAllByAtribuicoesCartorioId(@PathVariable int atribuicoesCartorioId) {
		return atribuicoesCartorioRepository.findAllByAtribuicoesCartorioId(atribuicoesCartorioId);
	}
	
	@GetMapping(value = "/atribuicoesCartorio")
	public Iterable<AtribuicoesCartorio> findAll() {
		return atribuicoesCartorioRepository.findAll();
	}
	
	@PostMapping(value = "/atribuicoesCartorio/atribuicoesCartorioAdd")
	public @ResponseBody AtribuicoesCartorio atribuicoesCartorioAdd(@RequestBody AtribuicoesCartorio novaAtribuicaoCartorio) {
	    return atribuicoesCartorioRepository.save(novaAtribuicaoCartorio);
	}
	
	@DeleteMapping(value = "/atribuicoesCartorio/delete/{atribuicoesCartorioId}")
	public String deleteById(@PathVariable("situacaoCartorioId") int id) {
		atribuicoesCartorioRepository.deleteById(id);
		return "Registro " + id + " excluído com sucesso.";
	}

}
