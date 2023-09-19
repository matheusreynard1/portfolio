package com.CartorioService.CartorioService.service;

import org.springframework.stereotype.Repository;
import com.CartorioService.CartorioService.domain.Cartorio;
import com.CartorioService.CartorioService.domain.SituacaoCartorio;
import com.CartorioService.CartorioService.repository.CartorioRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

@Repository
public abstract class CartorioRepositoryImpl implements CartorioRepository {
	
    @PersistenceContext
    EntityManager entityManager;
	
	public Cartorio findAllBySituacaoCartorioId(Cartorio cart, SituacaoCartorio sit) {
        /*Query query = entityManager.createNativeQuery("SELECT id FROM microsservico.cadastro_cartorio WHERE id = ?");
        query.setParameter(1, "situacao_cartorio_id");
        Cartorio cart = (Cartorio)query.getSingleResult();
        cart.setSituacao_cartorio(situacaoId);
		cart.setSituacao_cartorio(sit);*/
        return null;
	}

}
