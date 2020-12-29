import { Component, Inject } from '@angular/core'
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material'
@Component({
    template: `
        <h2 mat-dialog-title>確認</h2>

        <mat-dialog-content class="mat-typography">
            <pre style="white-space: pre-wrap">{{ dialogMessage }}</pre>
        </mat-dialog-content>

        <mat-dialog-actions align="end">
            <button
                mat-raised-button
                (click)="confirmDelete()"
                class="btn-accept"
            >
                はい
            </button>
            <button mat-raised-button mat-dialog-close>いいえ</button>
        </mat-dialog-actions>
    `,
    styles: [],
    providers: [],
})
export class ConfirmDeleteTagDialogComponent {
    dialogMessage = `「${this.parentData.name}」タグを削除してよろしいでしょうか？`
    constructor(
        public selfDialog: MatDialogRef<ConfirmDeleteTagDialogComponent>,
        @Inject(MAT_DIALOG_DATA) public parentData: any
    ) {
    }

    confirmDelete() {
    }
}
