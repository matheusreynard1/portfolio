package com.CartorioService.CartorioService.domain;

import java.io.Serializable;

import com.CartorioService.CartorioService.SituacaoCartorioEnum;
import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Table(name="cadastro_cartorio")
@Entity
public class Cartorio implements Serializable {

	private static final long serialVersionUID = 1L;
	
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name="id")
	@JsonProperty
	int cartorioId;
	
	@Column(name="nome")
	@JsonProperty
	String nome;
	
	@Column(name="observacao")
	@JsonProperty
	String observacao;
	
	@JsonProperty
	@Column(name="situacao_cartorio")
	@Enumerated(EnumType.STRING)
	SituacaoCartorioEnum situacao_cartorio;
	
	@Column(name="lista_atribuicoes")
	@JsonProperty
	int lista_atribuicoes;

	public SituacaoCartorioEnum getNomeEnum() {
		return situacao_cartorio;
	}

	public void setNomeEnum(SituacaoCartorioEnum nomeEnum) {
		this.situacao_cartorio = nomeEnum;
	}

	public int getCartorioId() {
		return cartorioId;
	}

	public void setCartorioId(int cartorioId) {
		this.cartorioId = cartorioId;
	}

	public String getNome() {
		return nome;
	}

	public void setNome(String nome) {
		this.nome = nome;
	}

	public String getObservacao() {
		return observacao;
	}

	public void setObservacao(String observacao) {
		this.observacao = observacao;
	}

	public int getLista_atribuicoes() {
		return lista_atribuicoes;
	}

	public void setLista_atribuicoes(int lista_atribuicoes) {
		this.lista_atribuicoes = lista_atribuicoes;
	}

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	
}
