package com.CartorioService.CartorioService.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.CartorioService.CartorioService.domain.Cartorio;

@Repository
public interface CartorioRepository extends JpaRepository<Cartorio, Integer> {
	
	Cartorio findAllByCartorioId(int id);
	List<Cartorio> findAll();
	@SuppressWarnings("unchecked")
	Cartorio save(Cartorio novoCartorio);
	String deleteById(int id);
	Cartorio save(int id);
	
}
