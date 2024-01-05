package com.SituacaoCartorioService.service;

import java.util.List;

import org.springframework.stereotype.Repository;

import com.SituacaoCartorioService.domain.Cartorio;
//import com.CartorioService.CartorioService.domain.Cartorio;
//import com.CartorioService.CartorioService.domain.SituacaoCartorio;
//import com.CartorioService.CartorioService.repository.CartorioRepository;
import com.SituacaoCartorioService.repository.SituacaoCartorioRepository;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;

@Repository
public abstract class SituacaoCartorioRepositoryImpl implements SituacaoCartorioRepository {
	
    @PersistenceContext
    EntityManager entityManager;

    /*@SuppressWarnings("unchecked")
	public List<Cartorio> findSituacaoInCartorio(int idSituacao) {
        Query query = entityManager.createNativeQuery("SELECT c1.id FROM cadastro_cartorio c1 LEFT JOIN situacao_cartorio c2 ON c1.situacao_cartorio_id = c2.id WHERE c1.situacao_cartorio_id = :idSituacao");
        query.setParameter("idSituacao", idSituacao);
        return query.getResultList();
    }
    */
}
