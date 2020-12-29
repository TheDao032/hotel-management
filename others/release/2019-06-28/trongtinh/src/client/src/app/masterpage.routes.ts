import { NgModule } from '@angular/core'
import { RouterModule, Routes } from '@angular/router'

import { MasterpageComponent } from './masterpage.component'
import { MypageComponent } from '../masterpage/mypage/mypage.component'
import { ImportKensyuuComponent } from './import/kensyuu/import-kensyuu.component'
import { TrainingInfoComponent } from './training/training-info/training-info.component'
import { SurveyComponent } from './survey/survey.component'
import { TrainingListComponent } from './training/training-list/training-list.component'
import { TrainingHistoryInfoComponent } from './training-history-info/training-history-info.component'
import { AnkettoImportComponent } from './import/anketto/anketto-import.component'
import { AnkettoExportComponent } from './export/anketto/anketto-export.component'
import { EmployeeHistoryComponent } from './employee-history/employee-history.component'
import { EmployeeHistoryInfoComponent } from './employee-history-info/employee-history-info.component'
import { TrainingApprovalComponent } from './training/training-approval/training-approval.component'
import { PermissionComponent } from './maintenance/permission/permission.component'
import { TrainingApplyListComponent } from './training/training-apply-list/training-apply-list.component'
import { KensyuuFormComponent } from './kanri/kensyuu/kensyuu-form/kensyuu-form.component'
import { NitteiFormComponent } from './kanri/nittei/nittei-form/nittei-form.component'
import { MailSettingsComponent } from './settings/mail-settings/mail-settings.component'

// Auth route
import { LeaveGuard } from '@app/auth/leave.guard'
import { AuthGuard } from '@app/auth/auth.guard'
import { Mod70Guard } from '@app/auth/mod70.guard'
import { AdminGuard } from '@app/auth/admin.guard'
import { EditMailComponent } from './settings/mail-settings/edit-mail/edit-mail.component'
import { UnSupportedBrowserComponent } from '@app/un-supported-browser/un-supported-browser.component'
import { ChartComponent } from './statistics/chart/chart.component'
import { RecommendSettingsComponent } from './settings/recommend-settings/recommend-settings.component';
import {SavedSettingsComponent} from './settings/saved-settings/saved-settings.component'
import { from } from 'rxjs';
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
                component: MypageComponent,
            },
            {
                path: 'survey/:moushikomi_id',
                component: SurveyComponent,
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
                    }
                ],
            },
            {
                path: 'training',
                children: [
                    {
                        path: 'info/:nittei_id',
                        component: TrainingInfoComponent,
                    },
                    {
                        path: 'list',
                        component: TrainingListComponent,
                    },
                    {
                        path: 'list/:ts',
                        component: TrainingListComponent,
                    },
                    {
                        path: 'approval',
                        component: TrainingApprovalComponent,
                        canActivate: [AdminGuard],
                        canDeactivate: [LeaveGuard],
                    },
                    {
                        path: 'apply-list',
                        canActivate: [Mod70Guard],
                        component: TrainingApplyListComponent,
                    },
                ],
            },
            {
                path: 'kanri',
                canActivate: [AdminGuard],
                children: [
                    {
                        path: 'kensyuu',
                        children: [
                            {
                                path: 'add',
                                component: KensyuuFormComponent, // doi thanh KensyuuFormComponent
                            },
                            {
                                path: 'edit/:kensyuu_id',
                                component: KensyuuFormComponent, // doi thanh KensyuuFormComponent
                            },
                        ],
                    },
                    {
                        path: 'nittei',
                        children: [
                            {
                                path: 'add/:kensyuu_id',
                                component: NitteiFormComponent, // doi thanh NitteiFormComponent
                            },
                            {
                                path: 'edit/:nittei_id',
                                component: NitteiFormComponent, // doi thanh NitteiFormComponent
                            },
                        ],
                    },
                ],
            },
            {
                path: 'history',
                canActivate: [AdminGuard],
                children: [
                    {
                        path: 'employee',
                        component: EmployeeHistoryComponent,
                    },
                    {
                        path: 'employee-details/:shain_cd',
                        component: EmployeeHistoryInfoComponent,
                    },
                    {
                        path:
                            'training-details/:kensyuu_id/:kensyuu_sub_id/:ki',
                        component: TrainingHistoryInfoComponent,
                    },
                ],
            },
            {
                path: 'maintenance',
                canActivate: [AdminGuard],
                children: [
                    {
                        path: 'permission',
                        component: PermissionComponent,
                    },
                ],
            },
            {
                path: 'export',
                canActivate: [AdminGuard],
                children: [
                    {
                        path: 'anketto',
                        component: AnkettoExportComponent,
                    },
                ],
            },
            {
                path: 'import',
                canActivate: [AdminGuard],
                children: [
                    {
                        path: 'kensyuu',
                        component: ImportKensyuuComponent,
                    },
                    {
                        path: 'anketto',
                        component: AnkettoImportComponent,
                    },
                ],
            },
            // {
            //     path: 'statistics',
            //     canActivate: [AdminGuard],
            //     children: [
            //         {
            //             path: 'charts',
            //             component: ChartComponent,
            //         },
            //     ],
            // },
        ],
    },
]

@NgModule({
    imports: [RouterModule.forChild(routes)],
    exports: [RouterModule],
})
export class RoutingMypage { }
// export const routingMypage: ModuleWithProviders = RouterModule.forChild(routes)
