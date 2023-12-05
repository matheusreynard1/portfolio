import { Component, OnInit, numberAttribute } from '@angular/core';
import { CartorioService } from '../cartorio.service'

@Component({
  selector: 'app-cartorios-atualizar',
  templateUrl: './cartorios-atualizar.component.html',
  styleUrls: ['./cartorios-atualizar.component.css']
})
export class CartoriosAtualizarComponent {
  cartorios: any;
  cadastro: any;

  constructor(private cartorioService: CartorioService) {
  
  }
  
  ngOnInit() {
    this.listar();
  }

  listar() {
    this.cartorioService.listar().subscribe(dados => this.cartorios = dados)
  }

  atualizar(id: string, nome: string, observacao: string) {
    var idNumero = Number(id)
    const atualizarCadastro = this.cartorioService.atualizar(idNumero, nome, observacao).subscribe(dados => this.cadastro = dados)
    if (atualizarCadastro != null) {
      this.exibirAlerta("Atualização realizada com sucesso");
      this.listar();
    } else {
      this.exibirAlerta("ERRO: impossível atualizar");    
    }
  }

  exibirAlerta(mensagem: string) {
    window.alert(mensagem)
  }
}
