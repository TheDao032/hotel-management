import { TestBed } from '@angular/core/testing'

import { MailSettingsService } from './mail-settings.service'

describe('MailSettingsService', () => {
    beforeEach(() => TestBed.configureTestingModule({}))

    it('should be created', () => {
        const service: MailSettingsService = TestBed.get(MailSettingsService)
        expect(service).toBeTruthy()
    })
})
