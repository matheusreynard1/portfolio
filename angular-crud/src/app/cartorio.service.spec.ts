import { TestBed } from '@angular/core/testing';

import { CartorioService } from './cartorio.service';

describe('CartorioService', () => {
  let service: CartorioService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(CartorioService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
