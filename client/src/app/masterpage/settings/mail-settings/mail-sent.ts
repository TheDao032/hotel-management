import { Component } from '@angular/core'
import * as common from '@app/common'

@Component({
    selector: 'app-mail-sent',
    template: `
        <h2 mat-dialog-title>メッセージ</h2>

        <mat-dialog-content class="mat-typography">
            <p>{{ mailSentMessage }}</p>
        </mat-dialog-content>

        <mat-dialog-actions align="end">
            <button mat-raised-button mat-dialog-close class="btn-accept">
                はい
            </button>
        </mat-dialog-actions>
    `,
})
export class MailSentComponent {
    mailSentMessage = 'DONE!'
    constructor() {}
}
