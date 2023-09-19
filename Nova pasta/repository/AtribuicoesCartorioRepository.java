package com.AtribuicoesCartorioService.repository;

import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import com.AtribuicoesCartorioService.domain.AtribuicoesCartorio;

@Repository
public interface AtribuicoesCartorioRepository extends CrudRepository<AtribuicoesCartorio, Integer> {
	
	AtribuicoesCartorio findAllByAtribuicoesCartorioId(int id);
	Iterable<AtribuicoesCartorio> findAll();
	@SuppressWarnings("unchecked")
	AtribuicoesCartorio save(AtribuicoesCartorio novaSituacaoCartorio);
	String deleteById(int id);

}
