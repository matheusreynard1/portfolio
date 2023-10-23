package com.SituacaoCartorioService.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import com.SituacaoCartorioService.domain.SituacaoCartorio;

public interface SituacaoCartorioRepository extends JpaRepository<SituacaoCartorio, Integer> {
	
	SituacaoCartorio findAllBySituacaoCartorioId(int id);
	List<SituacaoCartorio> findAll();
	@SuppressWarnings("unchecked")
	SituacaoCartorio save(SituacaoCartorio novaSituacaoCartorio);
	String deleteById(int id);
	SituacaoCartorio save(int id);
	
}
