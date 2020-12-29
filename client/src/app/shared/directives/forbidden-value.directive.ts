import { Directive, Input, OnChanges, SimpleChanges } from '@angular/core'
import {
    AbstractControl,
    NG_VALIDATORS,
    Validator,
    ValidatorFn,
    Validators,
} from '@angular/forms'

/** A hero's name can't match the given regular expression */
export function forbiddenValueValidator(v: string | string[]): ValidatorFn {
    return (control: AbstractControl): { [key: string]: any } | null => {
        const { value } = control
        if (value === '') return null
        const forbidden =
            (typeof v === 'string' && value === v) ||
            (Array.isArray(v) && v.indexOf(value) !== -1)
        return forbidden ? { forbiddenValue: { value } } : null
    }
}

@Directive({
    selector: '[appForbiddenValue]',
    providers: [
        {
            provide: NG_VALIDATORS,
            useExisting: ForbiddenValueDirective,
            multi: true,
        },
    ],
})
export class ForbiddenValueDirective {
    @Input('appForbiddenValue') forbiddenValue: string | string[]

    constructor() {}

    validate(control: AbstractControl): { [key: string]: any } | null {
        return this.forbiddenValue
            ? forbiddenValueValidator(this.forbiddenValue)(control)
            : null
    }
}
