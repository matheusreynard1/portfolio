import { Component, OnInit } from '@angular/core';
import { CartorioService } from '../cartorio.service'

@Component({
  selector: 'app-cartorios-listagemporid',
  templateUrl: './cartorios-listagemporid.component.html',
  styleUrls: ['./cartorios-listagemporid.component.css']
})
export class CartoriosListagemporidComponent implements OnInit{

cartorioPorId: any;

constructor(private cartorioService: CartorioService) {

}

ngOnInit() {
 
}

listarPorId(id: string) {
  const idNumber = parseFloat(id)
  this.cartorioService.listarPorId(idNumber).subscribe((dados) => this.cartorioPorId = dados)
}

}
