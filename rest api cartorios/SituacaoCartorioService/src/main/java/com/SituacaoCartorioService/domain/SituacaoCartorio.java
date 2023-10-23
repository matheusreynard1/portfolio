package com.SituacaoCartorioService.domain;

import java.io.Serializable;
import com.SituacaoCartorioService.SituacaoCartorioEnum;
import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
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
	@Column(name="nome_enum")
	@Enumerated(EnumType.STRING)
	SituacaoCartorioEnum nomeEnum;
	
	@JsonProperty
	@Column(name="nome")
	String nome;	
	
	public String nome() {
		return nomeEnum.getDescricao();
	}

	public void setNome(String nome) {
		this.nome = nome;
	}
	
	public int getId() {
		return situacaoCartorioId;
	}

	public void setId(int id) {
		this.situacaoCartorioId = id;
	}

	public SituacaoCartorioEnum getNome() {
		return nomeEnum;
	}

	public void setNome(SituacaoCartorioEnum nomeEnum) {
		this.nomeEnum = nomeEnum;
	}

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	
}

