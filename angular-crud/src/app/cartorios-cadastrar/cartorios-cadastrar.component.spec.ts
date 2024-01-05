import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CartoriosCadastrarComponent } from './cartorios-cadastrar.component';

describe('CartoriosCadastrarComponent', () => {
  let component: CartoriosCadastrarComponent;
  let fixture: ComponentFixture<CartoriosCadastrarComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [CartoriosCadastrarComponent]
    });
    fixture = TestBed.createComponent(CartoriosCadastrarComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
