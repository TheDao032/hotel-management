import { Component, OnInit, Inject } from '@angular/core'
import { MailSettingsService } from './mail-settings.service'
//import { rootRenderNodes } from '@angular/core/src/view'
//import { rootRenderNodes } from '@angular/'
import { Router } from '@angular/router'
import { MatSnackBar, MatDialog, MAT_DIALOG_DATA, MatRadioButton } from '@angular/material'
import { SharedService } from '@app/shared/shared.service'
import { MailSentComponent } from './mail-sent'
import { EditMailComponent } from './edit-mail/edit-mail.component'
import { configMail, MailMasterModel } from '@app/models/mail'
//import { Console } from '@angular/core/src/console'
import common from '@app/common'
import { element } from 'protractor'

@Component({
    selector: 'app-mail-settings',
    templateUrl: './mail-settings.component.html',
    styleUrls: ['./mail-settings.component.scss'],
    providers: [MailSettingsService],
})
export class MailSettingsComponent implements OnInit {
    isLoading = true
    secure2: boolean
    arrData = []
    formSettingMail = {
        id: 0,
        time: '',
        template_from_naiyou: '',
        mailFormData: [],
        host: '',
        port: 0,
        name_user: '',
        pass_user: '',
        secure: Boolean,
    }
    formData
    time
    mailFormData = new MailMasterModel({})
    public data: any[] = []
    id1
    checkSecure
    show_config = new configMail({})
    defaultMail = 'kyouiku@cubesystem.co.jp' // 'kyouiku@cubesystem.co.jp'
    constructor(
        private mailSettingsService: MailSettingsService,
        private router: Router,
        public snackBar: MatSnackBar,
        private sharedService: SharedService,
        public dialog: MatDialog
    ) {
        this.sharedService.setTitle('メール情報設定')
    }
    list_email = [
        {
            case: '申込',
            teacher: {
                link: '【とらんすふぉーむ】　申込',
                id: 'moushikomi_kyouiku',
                mail: 'kyouiku@cubesystem.co.jp',
            },
            shain: {
                link: '【とらんすふぉーむ】　申込',
                id: 'moushikomi_shain',
                mail: '受講者',
            },
            boss: {
                link: '【とらんすふぉーむ】　申込',
                id: 'moushikomi_boss',
                mail: '代理者',
            },
        },
        {
            case: 'キャンセル',
            teacher: {
                link: '【とらんすふぉーむ】　キャンセル',
                id: 'cancel_kyouiku',
                mail: 'kyouiku@cubesystem.co.jp',
            },
            shain: {
                link: '【とらんすふぉーむ】　キャンセル',
                id: 'cancel_shain',
                mail: '受講者',
            },
            boss: {
                link: '【とらんすふぉーむ】　キャンセル',
                id: 'cancel_boss',
                mail: '代理者',
            },
        },
    ]

    ngOnInit() {
        this.getDetailConfig()
        this.fetchMailFromInfo()
        this.detaiMailShukankikan()
        this.detailTimeSettingMail()
    }
    /*
        - Lấy dữ liệu mặc định cho fromSettingMail.time
    */
    detailTimeSettingMail() {
        this.mailSettingsService.getDetailTimeSettingMail(1).subscribe(
            (res) => {
                if (res.code === 1) {
                    return
                }
                //this.time = res.data.saving_day_send_mail
                this.formSettingMail.time = res.data.saving_day_send_mail
            },
            (error) => {}
        )
    }
    /*
        - Lấy dữ liệu mặc định cho shukankikan
    */
    detaiMailShukankikan() {
        this.mailSettingsService.getDatailMailShukankikan(1).subscribe(
            (res) => {
                this.data = res.data.map((i) => {
                    return {
                        ...i,
                    }
                })
                this.defaultMail = res.data[0].default_mail || this.defaultMail
            },
            (error) => {}
        )
    }

    detailEmail(id, mail) {
        const dialogRef = this.dialog.open(EditMailComponent, {
            data: { id, mail },
            panelClass: 'no-padding-dialog',
        })
    }

    fetchMailFromInfo() {
        this.mailSettingsService.getDetailFromMail(this.id1).subscribe(
            (res) => {
                this.mailFormData = new MailMasterModel(res.data)
            },
            (error) => {}
        )
    }
    /*
        - Lấy dữ liệu  từ server thành công khi code: 0 và thất bại code != 0
        - Lưu các dữ liệu lấy được vào configMail()
    */
    getDetailConfig() {
        this.mailSettingsService.getDetailConfig(this.id1).subscribe(
            (res) => {
                if (res.code === 0) {
                    this.show_config = new configMail(res.data)
                    this.secure2 = this.show_config.secure
                }
                if (res.code === 2 || res.code === 1) {
                    this.show_config = new configMail(res.data)
                    this.secure2 = this.show_config.secure
                }
                this.checkSecure = this.secure2.toString()

                //this.formSettingMail.secure = this.secure2
            },
            (error) => {},
            () => {
                this.isLoading = false
            }
        )
    }

    updateTemplateFrom(data = this.formSettingMail) {
        return this.mailSettingsService.updateTemplateFrom(data)
    }

    updateDaySendMail(data = this.formSettingMail) {
        return this.mailSettingsService.updateDaySendMail(data)
    }

    updateMailShukankikan(data = this.formSettingMail) {
        return this.mailSettingsService.updateMailShukankikan(data)
    }

    updateConfigMail(data = this.formSettingMail) {
        return this.mailSettingsService.updateConfigMail(data)
    }

    prepareDate() {
        this.formSettingMail.id = Number(this.show_config.id)
        this.formSettingMail.host = this.show_config.host
        this.formSettingMail.pass_user = this.show_config.passmail_auth
        this.formSettingMail.name_user = this.show_config.usermail_auth
        this.formSettingMail.secure = this.checkSecure
        this.formSettingMail.template_from_naiyou = this.mailFormData.template_from_naiyou
        this.formSettingMail.mailFormData = this.data
        this.formSettingMail.port = this.show_config.port
    }
    openSnackBar(data: string, time = 3000) {
        this.snackBar.open(data)
        setTimeout(() => this.snackBar.dismiss(), time)
    }
    updateFormMailSetting() {
        /*
            - Dữ liệu được chuẩn bị ở this.prepareDate()
            - Update all dữ liệu ở server nếu update thành công trả về code: 0 còn code !=0 thì lỗi
        */
        this.prepareDate()
        this.updateTemplateFrom().subscribe(
            (res) => {
                if (res.code === 0) {
                    //this.openSnackBar('template thanh cong', 1000)
                } else {
                    this.openSnackBar(common.message.SETT003)
                    return
                }
            },
            (err) => {
                this.openSnackBar(common.message.SETT003)
                return
            },
            () => {
                this.updateDaySendMail().subscribe(
                    (res1) => {
                        if (res1.code === 0) {
                            //this.openSnackBar('udate ngay goi mail thanh cong', 3000)
                        } else {
                            this.openSnackBar(common.message.SETT004)
                            return
                        }
                    },
                    (err) => {
                        this.openSnackBar(common.message.SETT004)
                        return
                    },
                    () => {
                        this.updateMailShukankikan().subscribe(
                            (res2) => {
                                if (res2.code === 0) {
                                    //this.openSnackBar('update mail shu thanh cong', 6000)
                                } else {
                                    this.openSnackBar(common.message.SETT005)
                                    return
                                }
                            },
                            (err) => {
                                this.openSnackBar(common.message.SETT005)
                                return
                            },
                            () => {
                                this.updateConfigMail().subscribe(
                                    (res3) => {
                                        if (res3.code === 0) {
                                            this.openSnackBar(common.message.SETT001)
                                        } else {
                                            this.openSnackBar(common.message.W033)
                                            return
                                        }
                                    },
                                    (err) => {
                                        this.openSnackBar(common.message.W033)
                                        return
                                    },
                                    () => {
                                        this.mailSettingsService.setDefaultMail(this.defaultMail).subscribe((res) => {
                                            console.log('Done')
                                        })
                                    }
                                )
                            }
                        )
                    }
                )
            }
        )
    }
}
