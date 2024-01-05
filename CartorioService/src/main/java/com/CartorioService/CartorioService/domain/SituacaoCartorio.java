package com.CartorioService.CartorioService.domain;

import java.io.Serializable;
import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

	
@Table(name="situacao_cartorio")
@Entity
public class SituacaoCartorio implements Serializable {

	private static final long serialVersionUID = 1L;
	
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name="id")
	@JsonProperty
	int situacaoCartorioId;
	
	@JsonProperty
	@Column(name="nome")
	String nome;
	
	@JsonProperty
	@Column(name="observacao")
	String observacao;	
	
	
	public int getId() {
		return situacaoCartorioId;
	}

	public void setId(int id) {
		this.situacaoCartorioId = id;
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

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	
}

