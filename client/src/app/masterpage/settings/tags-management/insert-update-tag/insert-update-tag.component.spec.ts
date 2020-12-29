import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { InsertUpdateTagComponent } from './insert-update-tag.component';

describe('InsertUpdateTagComponent', () => {
  let component: InsertUpdateTagComponent;
  let fixture: ComponentFixture<InsertUpdateTagComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ InsertUpdateTagComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(InsertUpdateTagComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
