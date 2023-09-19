package com.SituacaoCartorioService.repository;

import org.springframework.data.repository.CrudRepository;

import com.SituacaoCartorioService.domain.SituacaoCartorio;

public interface SituacaoCartorioRepository extends CrudRepository<SituacaoCartorio, Integer> {
	
	SituacaoCartorio findAllBySituacaoCartorioId(int id);
	Iterable<SituacaoCartorio> findAll();
	@SuppressWarnings("unchecked")
	SituacaoCartorio save(SituacaoCartorio novaSituacaoCartorio);
	String deleteById(int id);
	SituacaoCartorio save(int id);

}
