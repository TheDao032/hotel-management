import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { InsertUpdateCalendarComponent } from './insert-update-calendar.component';

describe('InsertUpdateCalendarComponent', () => {
  let component: InsertUpdateCalendarComponent;
  let fixture: ComponentFixture<InsertUpdateCalendarComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ InsertUpdateCalendarComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(InsertUpdateCalendarComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
