import { NgModule }             from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { CartoriosListagemComponent } from './cartorios-listagem/cartorios-listagem.component';
import { CartoriosListagemporidComponent } from './cartorios-listagemporid/cartorios-listagemporid.component';

const routes: Routes = [
  { path: 'gettodos', component: CartoriosListagemComponent },
  { path: 'getporid', component: CartoriosListagemporidComponent }
];

@NgModule({
  exports: [ RouterModule ],
  imports: [ RouterModule.forRoot(routes) ]
})

export class AppRoutingModule {}