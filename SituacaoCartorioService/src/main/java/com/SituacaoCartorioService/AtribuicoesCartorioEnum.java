package com.SituacaoCartorioService;

public enum AtribuicoesCartorioEnum {

	REG_NASC("Registro de nascimento"),
	REG_CASAM("Registro de casamento"),
	REG_OBITO("Registro de óbito"),
	AVERBACAO("Averbação");
	
	private String descricao;
	
	AtribuicoesCartorioEnum(String descricao) {
		this.descricao = descricao;
	}
	
	public String getDescricao() {
		return descricao;
	}
	
}
