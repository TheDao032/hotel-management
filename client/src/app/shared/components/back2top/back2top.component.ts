import { Component, Input } from '@angular/core'

@Component({
    selector: 'app-back2top',
    templateUrl: './back2top.component.html',
    styleUrls: ['./back2top.component.scss'],
})
export class Back2topComponent {
    @Input() isMobile: boolean
    @Input() totalRowInTable: number
    @Input() rowToShowButton: number

    constructor() {
        if (
            (this.totalRowInTable !== 0 && !this.totalRowInTable) ||
            (this.rowToShowButton !== 0 && !this.rowToShowButton)
        ) {
            this.totalRowInTable = 100
            this.rowToShowButton = 20
        }
    }

    scroll2Top() {
        const element = document.getElementsByClassName(
            'ui-table-scrollable-body'
        )[0]
        element.scrollTop = 0
    }
}
