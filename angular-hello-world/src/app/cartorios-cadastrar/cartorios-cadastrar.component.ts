import { Component, OnInit } from '@angular/core';
import { CartorioService } from '../cartorio.service'

@Component({
  selector: 'app-cartorios-cadastrar',
  templateUrl: './cartorios-cadastrar.component.html',
  styleUrls: ['./cartorios-cadastrar.component.css']
})
export class CartoriosCadastrarComponent implements OnInit {

  cartorios: any;
  cadastro: any;

  constructor(private cartorioService: CartorioService) {
  
  }
  
  ngOnInit() {
  }

  cadastrar(nome: string, observacao: string) {
    const novoCadastro = this.cartorioService.cadastrar(nome, observacao).subscribe(dados => this.cadastro = dados)
    if (novoCadastro != null) {
      this.exibirAlerta("Cadastro realizado com sucesso");
    } else {
      this.exibirAlerta("ERRO: impossível cadastrar");    
    }
  }

  exibirAlerta(mensagem: string) {
    window.alert(mensagem)
  }
}
