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
	@Query(value = "SELECT COALESCE(c1.id, '') AS id\r\n"
			+ "FROM cadastro_cartorio c1\r\n"
			+ "INNER JOIN situacao_cartorio c2 ON c1.situacao_cartorio = c2.nome\r\n"
			+ "WHERE c2.nome = :nomeSituacao", nativeQuery = true)
	String findCartorioComSituacaoCadastrada(@Param("nomeSituacao")String nomeSituacao);
	@Query(value = "UPDATE cadastro_cartorio SET situacao_cartorio = :nomeNovo WHERE situacao_cartorio = :nomeAntigo", nativeQuery = true)
	Cartorio alterarNomeSituacaoTabelaCartorios(String nomeNovo, String nomeAntigo);
	
	
}
