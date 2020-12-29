import { Pipe, PipeTransform } from '@angular/core'
import { fn } from '@app/common'
@Pipe({ name: 'stringByteLimit' })
export class StringByteLimitPipe implements PipeTransform {
    transform(value: any, ...args: any[]) {
        if (value === null || value === undefined) {
            return ''
        }
        const maxLength = (args[0] && Number(args[0])) || 24
        const v = String(value).trim()
        if (fn.lengthInUtf8Bytes(v) <= maxLength) {
            return v
        }
        let i = Math.min(8, v.length)
        while (
            i < v.length &&
            fn.lengthInUtf8Bytes(value.substring(0, i)) <= maxLength
        ) {
            i++
        }
        return value.substring(0, i - 1) + '...'
    }
}
