package com.SituacaoCartorioService.domain;

import java.io.Serializable;

import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;

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
	
	@Column(name="situacao_cartorio")
	@Transient
	@JsonProperty
	int situacao_cartorio;
	
	@Column(name="lista_atribuicoes")
	@JsonProperty
	int lista_atribuicoes;
	
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

	public int getSituacao_cartorio() {
		return situacao_cartorio;
	}

	public void setSituacao_cartorio(int situacao_cartorio) {
		this.situacao_cartorio = situacao_cartorio;
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
