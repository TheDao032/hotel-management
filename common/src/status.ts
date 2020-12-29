// export const status = [
//   '研修参加申請中', // index 0
//   '承認済み', // index 1
//   '研修先申込中', // index 2
//   '申込不可', // index 3
//   '開始待ち', // index 4
//   'アンケート回答待ち', // index 5
//   '経費精算待ち', // index 6
//   '完了', // index 7
//   'キャンセル依頼中', // index 8
//   'キャンセル', // index 9
//   'キャンセル（有償）'// index 10
// ]

class Status {
    readonly list: any[] = [
        { name: '研修参加申請中', value: 0, disabled: false },
        { name: '承認済み', value: 1, disabled: true },
        { name: '研修先申込中', value: 2, disabled: false },
        { name: '申込不可', value: 10, disabled: false },
        { name: '開始待ち', value: 3, disabled: false },
        { name: 'アンケート回答待ち', value: 4, disabled: false },
        { name: '経費精算待ち', value: 5, disabled: false },
        { name: '完了', value: 6, disabled: true },
        { name: 'キャンセル依頼中', value: 7, disabled: false },
        { name: 'キャンセル', value: 8, disabled: false },
        { name: 'キャンセル（有償）', value: 9, disabled: false },
        { name: '削除', value: 11, disabled: false, hide: true },
        { name: '開催中', value: 12, disabled: false, hide: true },
    ]
    constructor() {}
    getName(value): string {
        for (const v of this.list) if (v.value === Number(value)) return v.name
        return ''
    }
    getValue(value): string {
        for (const v of this.list) if (v.name === value) return v.value
        return ''
    }
}

export const status = new Status()
