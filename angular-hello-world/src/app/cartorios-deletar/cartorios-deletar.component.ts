import { Component, OnInit } from '@angular/core';
import { CartorioService } from '../cartorio.service'

@Component({
  selector: 'app-cartorios-deletar',
  templateUrl: './cartorios-deletar.component.html',
  styleUrls: ['./cartorios-deletar.component.css']
})
export class CartoriosDeletarComponent implements OnInit {

  cartorios: any;
  deletarCadastro: any;

  constructor(private cartorioService: CartorioService) {
  
  }
  
  ngOnInit() {
    this.listar();
  }

  listar() {
    this.cartorioService.listar().subscribe(dados => this.cartorios = dados)
  }

  deletar(id: number) {
    this.deletarCadastro = this.cartorioService.deletar(id).subscribe(dados => this.deletarCadastro = dados)
    if (this.deletarCadastro != null) {
      this.exibirAlerta("Cadastro excluído com sucesso");
      this.listar();
    } else {
      this.exibirAlerta("ERRO: impossível deletar");    
    }
  }

  exibirAlerta(mensagem: string) {
    window.alert(mensagem)
  }
}
