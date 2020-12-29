import { NgModule } from '@angular/core'
import { CommonModule } from '@angular/common'
import { FormsModule, ReactiveFormsModule } from '@angular/forms'

import { MaterialModule } from './material.module'
import { PrimengModule } from './primeng.module'
import { FlexLayoutModule } from '@angular/flex-layout'
import { Ng2CarouselamosModule } from 'ng2-carouselamos'

import { AcceptValueDirective } from './directives/accept-value.directive'
import { ForbiddenValueDirective } from './directives/forbidden-value.directive'
import { DevDirective } from './directives/dev.directive'

const imp = [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    MaterialModule,
    PrimengModule,
    FlexLayoutModule,
    Ng2CarouselamosModule,
]

const dec = [AcceptValueDirective, ForbiddenValueDirective, DevDirective]

@NgModule({
    imports: imp,
    declarations: dec,
    exports: [...imp, ...dec],
})
export class SharedModule {}
