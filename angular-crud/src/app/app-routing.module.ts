import { NgModule }             from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { CartoriosListagemComponent } from './cartorios-listagem/cartorios-listagem.component';
import { CartoriosListagemporidComponent } from './cartorios-listagemporid/cartorios-listagemporid.component';
import { CartoriosCadastrarComponent } from './cartorios-cadastrar/cartorios-cadastrar.component';
import { CartoriosDeletarComponent } from './cartorios-deletar/cartorios-deletar.component';
import { CartoriosAtualizarComponent } from './cartorios-atualizar/cartorios-atualizar.component';

const routes: Routes = [
  { path: 'gettodos', component: CartoriosListagemComponent },
  { path: 'getporid', component: CartoriosListagemporidComponent },
  { path: 'postcadastrar', component: CartoriosCadastrarComponent },
  { path: 'delete', component: CartoriosDeletarComponent },
  { path: 'putatualizar', component: CartoriosAtualizarComponent }
];

@NgModule({
  exports: [ RouterModule ],
  imports: [ RouterModule.forRoot(routes) ]
})

export class AppRoutingModule {}