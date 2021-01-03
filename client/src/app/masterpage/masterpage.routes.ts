import { NgModule } from '@angular/core'
import { RouterModule, Routes } from '@angular/router'

import { MasterpageComponent } from './masterpage.component'
import { homePageComponent } from './homepage/homepage.component'
import { MailSettingsComponent } from './settings/mail-settings/mail-settings.component'

// Auth route
import { LeaveGuard } from '@app/auth/leave.guard'
import { AuthGuard } from '@app/auth/auth.guard'
import { Mod70Guard } from '@app/auth/mod70.guard'
import { AdminGuard } from '@app/auth/admin.guard'
import { EditMailComponent } from './settings/mail-settings/edit-mail/edit-mail.component'
import { UnSupportedBrowserComponent } from '@app/un-supported-browser/un-supported-browser.component'
import { RecommendSettingsComponent } from './settings/recommend-settings/recommend-settings.component'

import { SavedSettingsComponent } from './settings/saved-settings/saved-settings.component'
import { from } from 'rxjs'
import { CalendarComponent } from './settings/calendar/calendar.component'
import { InsertUpdateCalendarComponent } from './settings/calendar/insert-update-calendar/insert-update-calendar.component'
//import { QRScannerCameraComponent } from './training/qrscanner-camera/qrscanner-camera.component'
import { TagsManagementComponent } from './settings/tags-management/tags-management.component'
const routes: Routes = [
    {
        path: '',
        component: MasterpageComponent, // parent Component
        canActivate: [AuthGuard],
        children: [
            {
                path: '',
                redirectTo: '/home',
                pathMatch: 'full',
            },
            {
                path: 'home',
                component: homePageComponent,
            },
            {
                path: 'settings',
                children: [
                    {
                        path: 'mail',
                        children: [
                            {
                                path: '',
                                component: MailSettingsComponent,
                            },
                            {
                                path: 'create-mail',
                                component: EditMailComponent,
                            },
                            {
                                path: 'edit-mail/:id_mail',
                                component: EditMailComponent,
                            },
                        ],
                    },
                    {
                        path: 'recommend',
                        component: RecommendSettingsComponent,
                    },
                    {
                        path: 'saved-setting',
                        component: SavedSettingsComponent,
                    },
                    {
                        path: 'calendar',
                        children: [
                            {
                                path: '',
                                component: CalendarComponent,
                            },
                            {
                                path: 'create-event',
                                component: InsertUpdateCalendarComponent,
                            },
                            {
                                path: 'edit-event/:id_event',
                                component: InsertUpdateCalendarComponent,
                            },
                        ],
                    },
                    {
                        path: 'tag-management',
                        component: TagsManagementComponent,
                    },
                ],
            },
        ],
    },
]
//End Update

@NgModule({
    imports: [RouterModule.forChild(routes)],
    exports: [RouterModule],
})
export class RoutingMypage {}
// export const routingMypage: ModuleWithProviders = RouterModule.forChild(routes)
