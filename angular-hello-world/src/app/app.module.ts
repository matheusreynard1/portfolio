import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule } from '@angular/common/http';
import { RouterModule } from '@angular/router';

import { AppComponent } from './app.component';
import { CartoriosListagemComponent } from './cartorios-listagem/cartorios-listagem.component';
import { CartorioService } from './cartorio.service';
import { AppRoutingModule } from './app-routing.module';
import { CartoriosListagemporidComponent } from './cartorios-listagemporid/cartorios-listagemporid.component';

@NgModule({
  declarations: [
    AppComponent,
    CartoriosListagemComponent,
    CartoriosListagemporidComponent,
  ],
  imports: [
    BrowserModule,
    HttpClientModule,
    RouterModule,
    AppRoutingModule
  ],
  providers: [ CartorioService ],
  bootstrap: [AppComponent]
})
export class AppModule { }
