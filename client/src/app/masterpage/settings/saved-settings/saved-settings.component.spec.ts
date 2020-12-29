import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { SavedSettingsComponent } from './saved-settings.component';

describe('SavedSettingsComponent', () => {
  let component: SavedSettingsComponent;
  let fixture: ComponentFixture<SavedSettingsComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ SavedSettingsComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(SavedSettingsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
