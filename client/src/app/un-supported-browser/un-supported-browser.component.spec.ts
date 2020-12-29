import { async, ComponentFixture, TestBed } from '@angular/core/testing'

import { UnSupportedBrowserComponent } from './un-supported-browser.component'

describe('UnSupportedBrowserComponent', () => {
    let component: UnSupportedBrowserComponent
    let fixture: ComponentFixture<UnSupportedBrowserComponent>

    beforeEach(async(() => {
        TestBed.configureTestingModule({
            declarations: [UnSupportedBrowserComponent],
        }).compileComponents()
    }))

    beforeEach(() => {
        fixture = TestBed.createComponent(UnSupportedBrowserComponent)
        component = fixture.componentInstance
        fixture.detectChanges()
    })

    it('should create', () => {
        expect(component).toBeTruthy()
    })
})
