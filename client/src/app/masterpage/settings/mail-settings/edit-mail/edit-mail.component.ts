import { Component, OnInit, Input, Inject } from '@angular/core'
import { ActivatedRoute, Router } from '@angular/router'
import { SharedService } from '@app/shared/shared.service'
import { MailSettingsService } from '../mail-settings.service'
import { MatSnackBar, MAT_DIALOG_DATA, MatDialog } from '@angular/material'
import { mail } from '@app/common'
import { MailMasterModel } from '@app/models/mail'
import common from '@app/common'
@Component({
    selector: 'app-edit-mail',
    templateUrl: './edit-mail.component.html',
    styleUrls: ['./edit-mail.component.scss'],
})
export class EditMailComponent implements OnInit {
    mailTemplateHeader = mail.mailTemplateHeader
    mailTemplateBodyLeft = []
    mailTemplateBodyRight = mail.mailTemplateBodyRight
    mailTemplateFooter = mail.mailTemplateFooter
    isLoading = true
    mailFormData = new MailMasterModel({})
    constructor(private sharedService: SharedService, public snackBar: MatSnackBar, private router: Router, public dialog: MatDialog, private mailSettingService: MailSettingsService, @Inject(MAT_DIALOG_DATA) public data: any = null) {
        // this.sharedService.setTitle('メールテンプレート編集')
    }

    ngOnInit() {
        this.fetchMailInfo(this.data.id)
    }

    submit() {}

    fetchMailInfo(id) {
        this.mailSettingService.getDetailMail(id).subscribe(
            (res) => {
                this.mailFormData = new MailMasterModel(res.data)
                if (this.mailFormData.template_id.includes('moushikomi')) {
                    this.mailTemplateBodyLeft = mail.mailTemplateBodyLeft.map((e) => {
                        if (e.id === 'template_cancel_day_regist') {
                            return {
                                ...e,
                                isShowed: false,
                            }
                        }

                        return e
                    })
                } else if (res.data.template_id.includes('cancel')) {
                    this.mailTemplateBodyLeft = mail.mailTemplateBodyLeft.map((e) => {
                        if (e.id === 'template_moushikomi_string') {
                            return {
                                ...e,
                                // name: '下記の通り、キャンセルがありました。',
                                name: '下記の申請がキャンセルされました。',
                            }
                        }
                        return e
                    })
                } else if (res.data.template_id === 'start_nittei') {
                    this.mailTemplateBodyLeft = mail.mailTemplateBodyLeft.map((e) => {
                        if (e.id === 'template_start_regist' || e.id === 'template_cancel_day_regist') {
                            return {
                                ...e,
                                isShowed: false,
                            }
                        }
                        if (e.id === 'template_moushikomi_string') {
                            return {
                                ...e,
                                name: '下記研修の申込が受理されました。',
                            }
                        }
                        return e
                    })
                } else if (res.data.template_id === 'end_nittei') {
                    this.mailTemplateBodyLeft = mail.mailTemplateBodyLeft.map((e) => {
                        if (e.id === 'template_start_regist' || e.id === 'template_end_regist' || e.id === 'template_policy_regist' || e.id === 'template_cancel_day_regist') {
                            return {
                                ...e,
                                isShowed: false,
                            }
                        }
                        if (e.id === 'template_moushikomi_string') {
                            return {
                                ...e,
                                name: `下記の研修は申込ができませんでした。\n詳細は別途お問い合わせください。`,
                            }
                        }

                        return e
                    })
                } else if (res.data.template_id === 'early_kyouiku') {
                    this.mailTemplateBodyLeft = mail.mailTemplateBodyLeft.map((e) => {
                        if (e.id === 'template_start_regist' || e.id === 'template_cancel_day_regist') {
                            return {
                                ...e,
                                isShowed: false,
                            }
                        }
                        if (e.id === 'template_moushikomi_string') {
                            return {
                                ...e,
                                name: `下記の通り、研修を受講予定です。`,
                            }
                        }

                        return e
                    })
                }
                else {
                    this.mailTemplateBodyLeft = mail.mailTemplateBodyLeft
                }
            },
            (error) => {},
            () => {
                this.isLoading = false
            }
        )
    }

    saveMail() {
        this.mailFormData.template_moushikomi_string_value  = this.mailTemplateBodyLeft.find((item) => item.id === 'template_moushikomi_string').name
        this.mailSettingService.saveMail(this.mailFormData).subscribe((res) => {
            if (res.code === 0) {
                this.snackBar.open(common.message.SETT001)
                setTimeout(() => this.snackBar.dismiss(), 3000)
                this.dialog.closeAll()
            } else {
                this.snackBar.open(common.message.SETT002)
                setTimeout(() => this.snackBar.dismiss(), 3000)
            }
        })
    }
}
