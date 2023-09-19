package com.SituacaoCartorioService;

public enum SituacaoCartorioEnum {

	SIT_ATIVO("Ativo"),
	SIT_BLOQUEADO("Bloqueado");
	
	private String descricao;
	
	SituacaoCartorioEnum(String descricao) {
		this.descricao = descricao;
	}
	
	public String getDescricao() {
		return descricao;
	}
	
}
