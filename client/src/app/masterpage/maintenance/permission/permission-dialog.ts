import { Component, Inject } from '@angular/core'
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material'

import * as common from '@app/common'
import { PermissionService } from './permission.service'
@Component({
    templateUrl: 'permission-dialog.html',
    styles: [],
    providers: [PermissionService],
})
export class PermissionDialogComponent {
    childData
    dataJPToEN = {
        shain_cd: '社員番号',
        permission_cd: '権限',
        shain_mei: '社員名',
        start_date: '適用開始日',
        end_date: '適用終了日',
    }
    errorMessage = ''
    shainList = []
    isCreate
    permissionList = ['01', '70', '99']
    constructor(
        public selfDialog: MatDialogRef<PermissionDialogComponent>,
        @Inject(MAT_DIALOG_DATA) public parentData: any,
        private permissionService: PermissionService
    ) {
        this.childData = { ...this.parentData.permissionData }
        this.isCreate = this.parentData.isCreate || false
        this.shainList = this.parentData.shainList || []
    }

    getShainMei() {
        this.childData.shain_mei =
            this.shainList.find((i) => i.shain_cd === this.childData.shain_cd)
                .shain_mei || ''
    }

    isValidData() {
        const formData = { ...this.childData }
        let errorMessage = ''
        const numberPattern = /^\d+$/
        for (const prop in formData) {
            if (!formData[prop]) {
                errorMessage = common.message.W010({
                    param: this.dataJPToEN[prop],
                })
                break
            }
        }
        if (errorMessage) return { isValid: !errorMessage, errorMessage }

        if (!numberPattern.test(this.childData.shain_cd))
            errorMessage = common.message.W011({ param: '社員番号' })
        if (!this.shainList.find((i) => i.shain_cd === formData.shain_cd))
            errorMessage = common.message.W013({ param: '社員番号' })
        if (formData.start_date > formData.end_date)
            errorMessage = common.message.W014

        return { isValid: !errorMessage, errorMessage }
    }

    addOrUpdatePermission() {
        const { isValid, errorMessage } = this.isValidData()
        this.errorMessage = errorMessage
        if (!isValid) {
            return
        }

        if (this.isCreate)
            this.permissionService
                .createNewPermission(this.childData)
                .subscribe(
                    (res) =>
                        this.selfDialog.close({
                            isCreate: this.isCreate,
                            success: true,
                        }),
                    (err) =>
                        this.selfDialog.close({
                            isCreate: this.isCreate,
                            success: false,
                        })
                )
        else
            this.permissionService.updatePermission(this.childData).subscribe(
                (res) =>
                    this.selfDialog.close({
                        isCreate: this.isCreate,
                        success: true,
                    }),
                (err) =>
                    this.selfDialog.close({
                        isCreate: this.isCreate,
                        success: false,
                    })
            )
    }
}
