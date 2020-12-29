import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { RecommendSettingsComponent } from './recommend-settings.component';

describe('RecommendSettingsComponent', () => {
  let component: RecommendSettingsComponent;
  let fixture: ComponentFixture<RecommendSettingsComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ RecommendSettingsComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(RecommendSettingsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
