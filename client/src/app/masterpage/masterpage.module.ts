import { NgModule } from '@angular/core'
import { MatButtonModule, MatDialogRef, MatIconModule, MatListModule, MatMenuModule, MatSidenavModule } from '@angular/material'

// routes
//Update By TheDao
import { Back2topComponent } from '../shared/components/back2top/back2top.component'
import { RoutingMypage } from './masterpage.routes'
import { MasterpageComponent } from './masterpage.component'
import { homePageComponent } from './homepage/homepage.component'
import { StringByteLimitPipe } from '../pipes/stringByteLimit'
import { MailSettingsComponent } from './settings/mail-settings/mail-settings.component'
import { EditMailComponent } from './settings/mail-settings/edit-mail/edit-mail.component'
import { MailSentComponent } from './settings/mail-settings/mail-sent'
import { RecommendSettingsComponent } from './settings/recommend-settings/recommend-settings.component'
import { SavedSettingsComponent } from './settings/saved-settings/saved-settings.component'
import { JwPaginationComponent } from 'jw-angular-pagination'
import { CalendarComponent } from './settings/calendar/calendar.component'
import { InsertUpdateCalendarComponent, ConfirmDiscardComponent } from './settings/calendar/insert-update-calendar/insert-update-calendar.component'
import { FullCalendarModule } from '@fullcalendar/angular'
import { ZXingScannerModule } from '@zxing/ngx-scanner';
import { TagsManagementComponent } from './settings/tags-management/tags-management.component';
import { InsertUpdateTagComponent } from './settings/tags-management/insert-update-tag/insert-update-tag.component'
import { ConfirmDeleteTagDialogComponent } from './settings/tags-management/confirm-delete-tag-dialog'
import { FormsModule } from '@angular/forms'
import { CommonModule } from '@angular/common'
import { MaterialModule } from '@app/shared/material.module'
import { SharedModule } from '../shared/shared.module'
@NgModule({
    imports: [SharedModule, RoutingMypage, FullCalendarModule, ZXingScannerModule, FormsModule, CommonModule, MaterialModule],
    declarations: [
        MasterpageComponent,
        homePageComponent,
        StringByteLimitPipe,
        MailSettingsComponent,
        EditMailComponent,
        MailSentComponent,
        RecommendSettingsComponent,
        SavedSettingsComponent,
        JwPaginationComponent,
        CalendarComponent,
        InsertUpdateCalendarComponent,
        ConfirmDiscardComponent,
        TagsManagementComponent,
        InsertUpdateTagComponent,
        ConfirmDeleteTagDialogComponent,
        Back2topComponent,
    ],
    exports: [],
    entryComponents: [
        MailSentComponent,
        ConfirmDiscardComponent,
        InsertUpdateTagComponent,
        ConfirmDeleteTagDialogComponent,
    ],
    providers: [{ provide: MatDialogRef, useValue: {} }],
})
//End Update
export class MasterpageModule {}
