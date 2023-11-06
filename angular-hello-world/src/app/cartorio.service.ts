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

  listarPorId(id: number): Observable<any> {
    return this.http.get<any[]>('http://localhost:6363/cartorio/' + id)
  }
}
