import * as common from '@app/common'
export class configMail {
    public id: string
    public host: string
    public port: number
    public secure: boolean
    public usermail_auth: string
    public passmail_auth: string
    constructor(data) {
        this.id = data.id
        this.host = data.host
        this.port = data.port
        this.secure = data.secure
        this.usermail_auth = data.usermail_auth
        this.passmail_auth = data.passmail_auth
    }
}
export class MailMasterModel {
    public template_id: string

    public template_from: boolean
    public template_from_naiyou: string
    public template_to: boolean
    public template_to_naiyou: string
    public template_cc: boolean
    public template_cc_naiyou: string
    public template_subject: boolean
    public template_subject_naiyou: string

    public template_auto_string: boolean
    public template_moushikomi_string: boolean
    public template_moushikomi_string_value: string
    public template_moushikomi_date: boolean
    public template_kensyuu_id: boolean
    public template_kensyuu_mei: boolean
    public template_shukankikan: boolean
    public template_start: boolean
    public template_end: boolean
    public template_fee: boolean
    public template_receiver_string: boolean
    public template_shain_cd: boolean
    public template_shain_name: boolean
    public template_mail: boolean
    public template_honbu: boolean
    public template_bumon: boolean
    public template_group: boolean

    public template_note: boolean
    public template_note_naiyou: string
    //them moi
    public template_start_regist: boolean
    public template_end_regist: boolean
    public template_policy_regist: boolean
    public template_cancel_day_regist: boolean

    constructor(data) {
        this.template_id = data.template_id
        this.template_from = data.template_from
        this.template_from_naiyou = data.template_from_naiyou
        this.template_to = data.template_to
        this.template_to_naiyou = data.template_to_naiyou
        this.template_cc = data.template_cc
        this.template_cc_naiyou = data.template_cc_naiyou
        this.template_subject = data.template_subject
        this.template_subject_naiyou = data.template_subject_naiyou

        this.template_auto_string = data.template_auto_string
        this.template_moushikomi_string = data.template_moushikomi_string
        this.template_moushikomi_string_value = data.template_moushikomi_string_value || data
        this.template_moushikomi_date = data.template_moushikomi_date
        this.template_kensyuu_id = data.template_kensyuu_id
        this.template_kensyuu_mei = data.template_kensyuu_mei
        this.template_shukankikan = data.template_shukankikan
        this.template_start = data.template_start
        this.template_end = data.template_end
        this.template_fee = data.template_fee
        this.template_receiver_string = data.template_receiver_string
        this.template_shain_cd = data.template_shain_cd
        this.template_shain_name = data.template_shain_name
        this.template_mail = data.template_mail
        this.template_honbu = data.template_honbu
        this.template_bumon = data.template_bumon
        this.template_group = data.template_group

        this.template_note = data.template_note
        this.template_note_naiyou = data.template_note_naiyou

        //them moi
        this.template_start_regist = data.template_start_regist
        this.template_end_regist = data.template_end_regist
        this.template_policy_regist = data.template_policy_regist
        this.template_cancel_day_regist = data.template_cancel_day_regist
    }
}
