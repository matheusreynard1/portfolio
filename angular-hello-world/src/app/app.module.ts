import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule } from '@angular/common/http';

import { AppComponent } from './app.component';
import { CartoriosListagemComponent } from './cartorios-listagem/cartorios-listagem.component';
import { CartorioService } from './cartorio.service';
import { AppRoutingModule } from './app-routing.module';
import { CartoriosListagemporidComponent } from './cartorios-listagemporid/cartorios-listagemporid.component';
import { CartoriosCadastrarComponent } from './cartorios-cadastrar/cartorios-cadastrar.component';
import { CartoriosDeletarComponent } from './cartorios-deletar/cartorios-deletar.component';
import { CartoriosAtualizarComponent } from './cartorios-atualizar/cartorios-atualizar.component';

@NgModule({
  declarations: [
    AppComponent,
    CartoriosListagemComponent,
    CartoriosListagemporidComponent,
    CartoriosCadastrarComponent,
    CartoriosDeletarComponent,
    CartoriosAtualizarComponent,
  ],
  imports: [
    BrowserModule,
    HttpClientModule,
    AppRoutingModule
  ],
  providers: [ CartorioService ],
  bootstrap: [AppComponent]
})
export class AppModule { }
