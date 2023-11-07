import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CartoriosAtualizarComponent } from './cartorios-atualizar.component';

describe('CartoriosAtualizarComponent', () => {
  let component: CartoriosAtualizarComponent;
  let fixture: ComponentFixture<CartoriosAtualizarComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [CartoriosAtualizarComponent]
    });
    fixture = TestBed.createComponent(CartoriosAtualizarComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
