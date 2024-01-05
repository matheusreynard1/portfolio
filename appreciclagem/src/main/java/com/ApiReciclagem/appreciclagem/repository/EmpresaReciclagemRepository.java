package com.ApiReciclagem.appreciclagem.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import com.ApiReciclagem.appreciclagem.domain.EmpresaReciclagem;

@Repository
public interface EmpresaReciclagemRepository extends JpaRepository<EmpresaReciclagem, Integer> {
	
	@Query(value = "SELECT * FROM empresa_reciclagem WHERE nome = :empresaNome AND senha = :empresaSenha", nativeQuery = true)
	EmpresaReciclagem realizarLogin(@Param("empresaNome") String empresaNome, @Param("empresaSenha") String empresaSenha);
	
	@Query(value = "SELECT * FROM empresa_reciclagem WHERE nome LIKE %:empresaNome%", nativeQuery = true)
	List<EmpresaReciclagem> findAllByEmpresaNome(@Param("empresaNome") String empresaNome);
	
	@Query(value = "SELECT * FROM empresa_reciclagem WHERE nome = :empresaNome", nativeQuery = true)
	List<EmpresaReciclagem> findNome(@Param("empresaNome") String empresaNome);
	
	List<EmpresaReciclagem> findAll();
	
	EmpresaReciclagem findAllByEmpresaId(int id);
	
	@SuppressWarnings("unchecked")
	EmpresaReciclagem save(EmpresaReciclagem novaEmpresa);
	
	String deleteById(int id);
	
}