import { Component, OnInit } from '@angular/core';
import { CartorioService } from '../cartorio.service'

@Component({
  selector: 'app-cartorios-listagem',
  templateUrl: './cartorios-listagem.component.html',
  styleUrls: ['./cartorios-listagem.component.css']
})
export class CartoriosListagemComponent implements OnInit{

cartorios: any;

constructor(private cartorioService: CartorioService) {

}

ngOnInit() {
  this.listar();
}

listar() {
  this.cartorioService.listar().subscribe(dados => this.cartorios = dados)
}

}
