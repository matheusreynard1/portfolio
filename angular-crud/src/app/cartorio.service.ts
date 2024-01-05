import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class CartorioService {

  constructor(private http: HttpClient) { }

  listar() {
    return this.http.get<any[]>('http://localhost:6363/cartorio')
  }

  listarPorId(id: number) {
    return this.http.get<any[]>('http://localhost:6363/cartorio/' + id)
  }

  cadastrar(nome: string, observacao: string) {
    const novoCartorio = this.gerarNovoCadastro(nome, observacao)
    return this.http.post('http://localhost:6363/cartorio/cartorioAdd', novoCartorio)
  }

  gerarNovoCadastro(nomeNovoCadastro: string, observacaoNovoCadsatro: string) {
    const novoCadastro = {
      nome: ''+ nomeNovoCadastro +'',
      observacao: ''+ observacaoNovoCadsatro +''
    }
    return novoCadastro
  }

  deletar(id: number) {
    return this.http.delete('http://localhost:6363/cartorio/delete/' + id)
  }

  atualizar(id: number, nome: string, observacao: string) {
    const novoCartorio = this.gerarNovoCadastro(nome, observacao)
    return this.http.put('http://localhost:6363/cartorio/alterar/' + id, novoCartorio)
  }
}
