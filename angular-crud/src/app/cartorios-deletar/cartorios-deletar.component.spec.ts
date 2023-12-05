import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CartoriosDeletarComponent } from './cartorios-deletar.component';

describe('CartoriosDeletarComponent', () => {
  let component: CartoriosDeletarComponent;
  let fixture: ComponentFixture<CartoriosDeletarComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [CartoriosDeletarComponent]
    });
    fixture = TestBed.createComponent(CartoriosDeletarComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
