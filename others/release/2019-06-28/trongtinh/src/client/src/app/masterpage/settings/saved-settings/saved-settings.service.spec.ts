import { TestBed } from '@angular/core/testing';

import { SavedSettingsService } from './saved-settings.service';

describe('SavedSettingsService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: SavedSettingsService = TestBed.get(SavedSettingsService);
    expect(service).toBeTruthy();
  });
});
