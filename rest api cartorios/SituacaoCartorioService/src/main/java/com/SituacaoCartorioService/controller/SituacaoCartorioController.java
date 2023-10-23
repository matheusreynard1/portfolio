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

import com.SituacaoCartorioService.domain.SituacaoCartorio;
import com.SituacaoCartorioService.repository.SituacaoCartorioRepository;

@RestController
public class SituacaoCartorioController {
	
	@Autowired
	SituacaoCartorioRepository situacaoCartorioRepository;
	
	@PutMapping(value = "/situacaoCartorio/alterar/{situacaoCartorioId}")
	public SituacaoCartorio alterar(@RequestBody SituacaoCartorio situacaoAlterada, @PathVariable int situacaoCartorioId) {
		SituacaoCartorio situ = findAllBySituacaoCartorioId(situacaoCartorioId);
		situ.setNome(situacaoAlterada.getNome());
		situacaoCartorioRepository.save(situ);
		return situ;
	}
	
	@GetMapping(value = "/situacaoCartorio/{situacaoCartorioId}")
	public SituacaoCartorio findAllBySituacaoCartorioId(@PathVariable int situacaoCartorioId) {
		return situacaoCartorioRepository.findAllBySituacaoCartorioId(situacaoCartorioId);
	}
	
	@GetMapping(value = "/situacaoCartorio")
	public List<SituacaoCartorio> findAll() {
		return situacaoCartorioRepository.findAll();
		
	}
	
	@PostMapping(value = "/situacaoCartorio/situacaoCartorioAdd")
	public @ResponseBody SituacaoCartorio situacaoCartorioAdd(@RequestBody SituacaoCartorio novaSituacaoCartorio) {
	    return situacaoCartorioRepository.save(novaSituacaoCartorio);
	}
	
	@DeleteMapping(value = "/situacaoCartorio/delete/{situacaoCartorioId}")
	public String deleteById(@PathVariable("situacaoCartorioId") int id) {
		situacaoCartorioRepository.deleteById(id);
		return "Registro " + id + " excluído com sucesso.";
	}

}
