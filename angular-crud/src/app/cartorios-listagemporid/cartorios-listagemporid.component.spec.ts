import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CartoriosListagemporidComponent } from './cartorios-listagemporid.component';

describe('CartoriosListagemporidComponent', () => {
  let component: CartoriosListagemporidComponent;
  let fixture: ComponentFixture<CartoriosListagemporidComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [CartoriosListagemporidComponent]
    });
    fixture = TestBed.createComponent(CartoriosListagemporidComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
