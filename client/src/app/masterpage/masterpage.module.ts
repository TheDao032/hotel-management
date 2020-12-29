import { NgModule } from '@angular/core'
import { MatDialogRef } from '@angular/material'

// routes
//Update By TheDao
import { RoutingMypage } from './masterpage.routes'
import { MasterpageComponent } from './masterpage.component'
import { homePageComponent } from './homepage/homepage.component'
import { PermissionComponent } from './maintenance/permission/permission.component'
import { StringByteLimitPipe } from '../pipes/stringByteLimit'
import { PermissionDialogComponent } from './maintenance/permission/permission-dialog'
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
@NgModule({
    imports: [RoutingMypage, FullCalendarModule, ZXingScannerModule],
    declarations: [
        PermissionDialogComponent,
        MasterpageComponent,
        homePageComponent,
        PermissionComponent,
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
    ],
    exports: [],
    entryComponents: [
        PermissionDialogComponent,
        MailSentComponent,
        ConfirmDiscardComponent,
        InsertUpdateTagComponent,
        ConfirmDeleteTagDialogComponent,
    ],
    providers: [{ provide: MatDialogRef, useValue: {} }],
})
//End Update
export class MasterpageModule {}
