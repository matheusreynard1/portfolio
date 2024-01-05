package com.SituacaoCartorioService.domain;

import java.io.Serializable;

import com.SituacaoCartorioService.AtribuicoesCartorioEnum;
import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Table(name="atribuicao_cartorio")
@Entity
public class AtribuicoesCartorio implements Serializable {

	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name="id")
	@JsonProperty
	Integer atribuicoesCartorioId;
	
	@JsonProperty
	@Column(name="nome")
	@Enumerated(EnumType.STRING)
	AtribuicoesCartorioEnum nome;
	
	@JsonProperty
	@Column(name="tipo")
	int tipo = 1;
	
	public int getId() {
		return atribuicoesCartorioId;
	}

	public void setId(int id) {
		this.atribuicoesCartorioId = id;
	}

	public AtribuicoesCartorioEnum getNome() {
		return nome;
	}

	public void setNome(AtribuicoesCartorioEnum nome) {
		this.nome = nome;
	}

	public int getTipo() {
		return tipo;
	}

	public void setTipo(int tipo) {
		this.tipo = tipo;
	}

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	
}
