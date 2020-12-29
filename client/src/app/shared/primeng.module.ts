import { NgModule } from '@angular/core'

import { CalendarModule } from 'primeng/calendar'
// import { CheckboxModule } from 'primeng/checkbox'
// import { DataTableModule } from 'primen'
import { TableModule } from 'primeng/table'
// import { RadioButtonModule } from 'primeng/radiobutton'

const list = [
    CalendarModule,
    // CheckboxModule,
    // DataTableModule,
    // RadioButtonModule,
    TableModule,
]

@NgModule({
    imports: list,
    exports: list,
    declarations: [],
})
export class PrimengModule {}
