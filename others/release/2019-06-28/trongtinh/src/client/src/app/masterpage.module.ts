import { NgModule } from '@angular/core'
import { SharedModule } from '../shared/shared.module'
import { MatDialogRef } from '@angular/material'

// routes
import { RoutingMypage } from './masterpage.routes'
import { MasterpageComponent } from './masterpage.component'
import { MypageComponent } from './mypage/mypage.component'
import { SurveyComponent } from './survey/survey.component'
import { TrainingApprovalComponent } from './training/training-approval/training-approval.component'
import { TrainingHistoryInfoComponent } from './training-history-info/training-history-info.component'
import { TrainingListComponent } from './training/training-list/training-list.component'
import {
    TrainingInfoComponent,
    CancelPolicyComponent,
} from './training/training-info/training-info.component'
import { DeleteKensyuuDialogComponent } from './import/kensyuu/deleteKensyuuDialog'
import { ImportKensyuuDialogComponent } from './import/kensyuu/importKensyuuDialog'
import { PermissionComponent } from './maintenance/permission/permission.component'
import { KensyuuFormComponent } from './kanri/kensyuu/kensyuu-form/kensyuu-form.component'
import { NitteiFormComponent } from './kanri/nittei/nittei-form/nittei-form.component'
import { StringByteLimitPipe } from '../pipes/stringByteLimit'
import { AnkettoImportComponent } from './import/anketto/anketto-import.component'
import { EmployeeHistoryInfoComponent } from './employee-history-info/employee-history-info.component'
import { EmployeeHistoryComponent } from './employee-history/employee-history.component'
import { ImportKensyuuComponent } from './import/kensyuu/import-kensyuu.component'
import { AnkettoExportComponent } from './export/anketto/anketto-export.component'
import { AnkettoImportDialogComponent } from './import/anketto/anketto-import-dialog'
import { EmployeeHistoryDialogComponent } from './employee-history/employee-history-dialog'
import { PermissionDialogComponent } from './maintenance/permission/permission-dialog'
import { SurveyDialogComponent } from './survey/survey-dialog'
import { RatingStarComponent } from '../shared/components/rating-star/rating-star.component'
import { Back2topComponent } from '../shared/components/back2top/back2top.component'
import { JoinerListComponent } from './training/training-info/joiner-list/joiner-list.component'
import { KensyuuNitteiInfoComponent } from './training/training-info/kensyuu-nittei-info/kensyuu-nittei-info.component'
import { KensyuuRatingComponent } from './training/training-info/kensyuu-rating/kensyuu-rating.component'
import { KensyuuCommentComponent } from './training/training-info/kensyuu-comment/kensyuu-comment.component'
import { KensyuuSuggestComponent } from './training/training-info/kensyuu-suggest/kensyuu-suggest.component'
import { TrainingApplyListComponent } from './training/training-apply-list/training-apply-list.component'
import { MailSettingsComponent } from './settings/mail-settings/mail-settings.component'
import { EditMailComponent } from './settings/mail-settings/edit-mail/edit-mail.component'
import { MailSentComponent } from './settings/mail-settings/mail-sent';
import { ChartComponent } from './statistics/chart/chart.component';
import { RecommendSettingsComponent } from './settings/recommend-settings/recommend-settings.component';
import { SavedSettingsComponent } from './settings/saved-settings/saved-settings.component'

@NgModule({
    imports: [SharedModule, RoutingMypage],
    declarations: [
        DeleteKensyuuDialogComponent,
        SurveyDialogComponent,
        PermissionDialogComponent,
        EmployeeHistoryDialogComponent,
        ImportKensyuuDialogComponent,
        MasterpageComponent,
        MypageComponent,
        TrainingInfoComponent,
        CancelPolicyComponent,
        ImportKensyuuComponent,
        TrainingHistoryInfoComponent,
        TrainingListComponent,
        SurveyComponent,
        AnkettoImportComponent,
        EmployeeHistoryComponent,
        EmployeeHistoryInfoComponent,
        TrainingApprovalComponent,
        PermissionComponent,
        KensyuuFormComponent,
        NitteiFormComponent,
        StringByteLimitPipe,
        AnkettoExportComponent,
        AnkettoImportDialogComponent,
        RatingStarComponent,
        Back2topComponent,
        JoinerListComponent,
        KensyuuNitteiInfoComponent,
        KensyuuRatingComponent,
        KensyuuCommentComponent,
        KensyuuSuggestComponent,
        TrainingApplyListComponent,
        MailSettingsComponent,
        EditMailComponent,
        MailSentComponent,
        ChartComponent,
        RecommendSettingsComponent,
        SavedSettingsComponent,
    ],
    exports: [],
    entryComponents: [
        CancelPolicyComponent,
        KensyuuFormComponent,
        NitteiFormComponent,
        DeleteKensyuuDialogComponent,
        ImportKensyuuDialogComponent,
        EmployeeHistoryDialogComponent,
        AnkettoImportDialogComponent,
        PermissionDialogComponent,
        SurveyDialogComponent,
        MailSentComponent,
    ],
    providers: [{ provide: MatDialogRef, useValue: {} }],
})
export class MasterpageModule {}
