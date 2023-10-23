package com.CartorioService.CartorioService.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
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
	@Query(value = "SELECT TOP 1 * FROM cadastro_cartorio c1 INNER JOIN situacao_cartorio c2 ON c1.situacao_cartorio = c2.nome_enum", nativeQuery = true)
	Integer findSituacoesComCartorioCadastrado(@Param("idSituacao")int idSituacao);
	
}
