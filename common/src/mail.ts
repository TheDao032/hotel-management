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
    ]
    readonly mailTemplateBodyRight: any[] = [
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
