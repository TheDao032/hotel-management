const thirdCharKensyuuList = ['5', '6']
const htmlMail = `
    <p>template_auto_string<p>
    <p>template_moushikomi_string</p>
    <p>template_moushikomi_date</p>
    <p>template_kensyuu_id</p>
    <p>template_kensyuu_mei</p>
    <p>template_shukankikan<p>
    <p>template_start</p>
    <p>template_end</p>
    <p>template_cancel_day_regist</p>
    <p>template_start_regist</p>
    <p>template_end_regist</p>
    <p>template_policy_regist</p>
    <p>template_fee</p>
    <p>template_receiver_string</p>
    <p>template_shain_cd</p>
    <p>template_shain_name</p>
    <p>template_mail</p>
    <p>template_honbu</p>
    <p>template_bumon</p>
    <p>template_group</p>
    <p>template_note_naiyou</p>
    <p><img src="template_qr"></p>
`

const htmlMailValue = [
    {
        id: 'template_auto_string',
        value: '（本メールは自動配信です。）',
    },
    {
        id: 'template_moushikomi_string',
        value: '下記の通り、申請がありました。',
    },
    {
        id: 'template_recevier_string',
        value: '受講者情報は以下の通りです',
    },
]

const convertToMailModel = (template, moushikomi, kensyuu, to) => {
    return {
        template_qr: moushikomi.shain_qr ? moushikomi.shain_qr : '',
        template_from: template.template_from && template.template_from_naiyou ? template.template_from_naiyou : '',
        template_to: template.template_to && to ? to : '',
        template_cc: template.template_cc && template.template_cc_naiyou ? template.template_cc_naiyou : '',
        template_subject: template.template_subject && template.template_subject_naiyou ? template.template_subject_naiyou : '',
        template_auto_string: template.template_auto_string ? '（本メールは自動配信です。）' : '',
        template_moushikomi_string: template.template_moushikomi_string ? template.template_moushikomi_string_value : '下記の通り、申請がありました。',
        template_moushikomi_date: template.template_moushikomi_date && moushikomi.moushikomi_date ? `申込日時：${moushikomi.moushikomi_date}` : '',
        template_kensyuu_id: template.template_kensyuu_id && kensyuu.kensyuu_id ? `研修ID：${kensyuu.kensyuu_id}` : '',
        template_kensyuu_mei: template.template_kensyuu_mei && kensyuu.kensyuu_mei ? `研修名： ${kensyuu.kensyuu_mei}` : '',
        template_shukankikan: template.template_shukankikan && kensyuu.shukankikan ? `主管組織：${kensyuu.shukankikan}` : '',
        template_start: template.template_start && kensyuu.nittei_from ? `研修開始日：${kensyuu.nittei_from}` : '',
        template_end: template.template_end && kensyuu.nittei_to ? `研修終了日：${kensyuu.nittei_to}` : '',
        template_fee: template.template_fee && kensyuu.jyukouryou ? `金額：${kensyuu.jyukouryou}` : '',
        template_receiver_string: template.template_receiver_string ? '受講者の情報は以下の通りです。' : '',
        template_shain_cd: template.template_shain_cd && moushikomi.shain_cd ? `社員番号：${moushikomi.shain_cd}` : '',
        template_shain_name: template.template_shain_name && moushikomi.shain_mei ? `氏名：${moushikomi.shain_mei}` : '',
        template_mail: template.template_mail && moushikomi.mail_address ? `メール： ${moushikomi.mail_address}` : '',
        template_honbu: template.template_honbu && moushikomi.honbu_nm ? `本部：${moushikomi.honbu_nm}` : '',
        template_bumon: template.template_bumon && moushikomi.bumon_nm ? `部門：${moushikomi.bumon_nm}` : '',
        template_group: template.template_group && moushikomi.group_nm ? `グループ： ${moushikomi.group_nm}` : '',
        template_note_naiyou: template.template_note && template.template_note_naiyou ? `備考：${template.template_note_naiyou}` : '',
        // them moi
        template_start_regist: template.template_start_regist && kensyuu.moushikomikigen ? `研修申込締切日: ${kensyuu.moushikomikigen}` : '',
        template_end_regist: template.template_end_regist && kensyuu.cancel_date ? `研修キャンセル締切日: ${kensyuu.cancel_date}` : '',
        template_policy_regist: template.template_policy_regist && kensyuu.cancelpolicy ? `研修キャンセルポリシー: ${kensyuu.cancelpolicy}` : '',
        template_cancel_day_regist: template.template_cancel_day_regist && moushikomi.moushikomi_date ? `キャンセル日時: ${moushikomi.moushikomi_date}` : '',
    }
}

module.exports = {
    thirdCharKensyuuList,
    htmlMail,
    htmlMailValue,
    convertToMailModel,
}
