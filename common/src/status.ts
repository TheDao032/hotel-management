class Status {
    readonly list: any[] = [
        { name: 'unActive', value: 0, disabled: false },
        { name: 'active', value: 1, disabled: true },
        { name: 'expired', value: 2, disabled: false },
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
