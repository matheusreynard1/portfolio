package com.SituacaoCartorioService.repository;

import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import com.SituacaoCartorioService.domain.AtribuicoesCartorio;

@Repository
public interface AtribuicoesCartorioRepository extends CrudRepository<AtribuicoesCartorio, Integer> {
	
	AtribuicoesCartorio findAllById(int id);
	Iterable<AtribuicoesCartorio> findAll();
	@SuppressWarnings("unchecked")
	AtribuicoesCartorio save(AtribuicoesCartorio novaAtribuicaoCartorio);
	String deleteById(int id);
	AtribuicoesCartorio save(int id);

}
