import { Component, Inject } from '@angular/core'
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material'
import { TagsService } from '@app/masterpage/training/training-info/tags/tags.service'
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
    providers: [TagsService],
})
export class ConfirmDeleteTagDialogComponent {
    dialogMessage = `「${this.parentData.name}」タグを削除してよろしいでしょうか？`
    constructor(
        public selfDialog: MatDialogRef<ConfirmDeleteTagDialogComponent>,
        private tagsService: TagsService,
        @Inject(MAT_DIALOG_DATA) public parentData: any
    ) {
    }

    confirmDelete() {
        this.tagsService.deleteTag(this.parentData.id).subscribe((res) => {
            this.selfDialog.close({
                type: 'delete',
                success: true,
            })
        }),
        (err) =>{
            this.selfDialog.close({
                type: 'delete',
                success: false,
            })
        }
    }
}
