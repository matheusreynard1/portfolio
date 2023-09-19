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

	
@Table(name="situacao_cartorio")
@Entity
public class SituacaoCartorio implements Serializable {

	private static final long serialVersionUID = 1L;
	
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name="id")
	@JsonProperty
	int situacao_cartorio_id;
	
	@JsonProperty
	@Column(name="nome")
	@Enumerated(EnumType.STRING)
	SituacaoCartorioEnum nome;
	
	public int getId() {
		return situacao_cartorio_id;
	}

	public void setId(int id) {
		this.situacao_cartorio_id = id;
	}

	public String getNome() {
		return nome.getDescricao();
	}

	public void setNome(SituacaoCartorioEnum nome) {
		this.nome = nome;
	}

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	
}

