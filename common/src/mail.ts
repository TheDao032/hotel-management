class MailSettingOptions {
    readonly mailTemplateHeader: any[] = [
        {
            name: 'From',
            id: 'template_from',
            isShowed: true,
            value: '',
            suffix: '_naiyou',
            display: false,
        },
        {
            name: '宛先',
            id: 'template_to',
            isShowed: true,
            value: '',
            suffix: '_naiyou',
            display: false,
        },
        {
            name: 'CC',
            id: 'template_cc',
            isShowed: true,
            value: '',
            suffix: '_naiyou',
            display: false,
        },
        {
            name: '件名',
            id: 'template_subject',
            isShowed: true,
            value: '',
            suffix: '_naiyou',
            display: true,
        },
    ]
    readonly mailTemplateBodyLeft: any[] = [
        {
            name: '（本メールは自動配信です。）',
            id: 'template_auto_string',
            isShowed: true,
        },
        {
            name: '下記の通り、申請がありました。',
            id: 'template_moushikomi_string',
            isShowed: true,
        },
        { name: '申込日時', id: 'template_moushikomi_date', isShowed: true },
        { name: 'キャンセル日時', id: 'template_cancel_day_regist', isShowed: true }, //Ngày hủy
        { name: '研修ID', id: 'template_kensyuu_id', isShowed: true },
        { name: '研修名', id: 'template_kensyuu_mei', isShowed: true },
        { name: '主管組織	', id: 'template_shukankikan', isShowed: true },
        { name: '研修開始日', id: 'template_start', isShowed: true },
        { name: '研修終了日', id: 'template_end', isShowed: true },
        { name: '研修申込締切日', id: 'template_start_regist', isShowed: true }, //Ngày hết hạn đăng ký khóa học
        { name: '研修キャンセル締切日', id: 'template_end_regist', isShowed: true }, //Ngày hết hạn hủy khóa học
        { name: '研修キャンセルポリシー', id: 'template_policy_regist', isShowed: true }, //Chính sách khi hủy khóa học
    ]
    readonly mailTemplateBodyRight: any[] = [
        { name: '金額', id: 'template_fee', isShowed: true },
        {
            // name: '以下の受講者の情報です。',
            // name: '受講者情報は以下の通りです。',
            name: '受講者の情報は以下の通りです。',
            id: 'template_receiver_string',
            isShowed: true,
        },
        { name: '社員番号', id: 'template_shain_cd', isShowed: true },
        { name: '氏名', id: 'template_shain_name', isShowed: true },
        { name: 'メール	', id: 'template_mail', isShowed: true },
        { name: '本部', id: 'template_honbu', isShowed: true },
        { name: '部門', id: 'template_bumon', isShowed: true },
        { name: 'グループ', id: 'template_group', isShowed: true },
    ]
    readonly mailTemplateFooter: any[] = [
        {
            name: '備考',
            id: 'template_note',
            isShowed: true,
            value: '',
            suffix: '_naiyou',
        },
    ]

    constructor() {}
}

export const mail = new MailSettingOptions()
