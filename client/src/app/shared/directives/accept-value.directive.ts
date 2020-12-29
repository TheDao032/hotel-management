import { Directive, Input, OnChanges, SimpleChanges } from '@angular/core'
import {
    AbstractControl,
    NG_VALIDATORS,
    Validator,
    ValidatorFn,
    Validators,
} from '@angular/forms'

/** A hero's name can't match the given regular expression */
export function acceptValueValidator(v: string[]): ValidatorFn {
    return (control: AbstractControl): { [key: string]: any } | null => {
        const { value } = control
        if (value === '') return null
        const accept = v.indexOf(value) !== -1
        return accept ? null : { notInList: { value } }
    }
}

@Directive({
    selector: '[appAcceptValue]',
    providers: [
        {
            provide: NG_VALIDATORS,
            useExisting: AcceptValueDirective,
            multi: true,
        },
    ],
})
export class AcceptValueDirective implements Validator {
    @Input('appAcceptValue') acceptValue: string[]
    constructor() {}

    validate(control: AbstractControl): { [key: string]: any } | null {
        return this.acceptValue
            ? acceptValueValidator(this.acceptValue)(control)
            : null
    }
}
