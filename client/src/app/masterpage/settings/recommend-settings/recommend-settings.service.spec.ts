import { TestBed } from '@angular/core/testing';

import { RecommendSettingsService } from './recommend-settings.service';

describe('RecommendSettingsService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: RecommendSettingsService = TestBed.get(RecommendSettingsService);
    expect(service).toBeTruthy();
  });
});
