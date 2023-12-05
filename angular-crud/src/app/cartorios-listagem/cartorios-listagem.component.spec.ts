import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CartoriosListagemComponent } from './cartorios-listagem.component';

describe('CartoriosListagemComponent', () => {
  let component: CartoriosListagemComponent;
  let fixture: ComponentFixture<CartoriosListagemComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [CartoriosListagemComponent]
    });
    fixture = TestBed.createComponent(CartoriosListagemComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
