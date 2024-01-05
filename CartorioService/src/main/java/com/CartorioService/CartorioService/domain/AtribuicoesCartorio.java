package com.CartorioService.CartorioService.domain;

import java.io.Serializable;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Table(name="atribuicao_cartorio")
@Entity
public class AtribuicoesCartorio implements Serializable {

	private static final long serialVersionUID = 1L;

	@Id
	@Column(name="id")
	String id;
	
	@Column(name="nome")
	String nome;
	
	@Column(name="tipo")
	boolean tipo = true;
	
	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getNome() {
		return nome;
	}

	public void setNome(String nome) {
		this.nome = nome;
	}

	public boolean isTipo() {
		return tipo;
	}

	public void setTipo(boolean tipo) {
		this.tipo = tipo;
	}

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	
}
