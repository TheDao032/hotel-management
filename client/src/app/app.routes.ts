import { NgModule } from '@angular/core'
import { RouterModule, Routes } from '@angular/router'

import { AuthGuard } from '@app/auth/auth.guard'
import { UnauthGuard } from '@app/auth/unauth.guard'

import { LoginComponent } from './login/login.component'
import { UnSupportedBrowserComponent } from './un-supported-browser/un-supported-browser.component'
const routes: Routes = [
    {
        path: 'un-supported-browser',
        component: UnSupportedBrowserComponent,
    },
    { path: 'login', canActivate: [UnauthGuard], component: LoginComponent },
    {
        path: '',
        canLoad: [AuthGuard],
        loadChildren: './masterpage/masterpage.module#MasterpageModule',
    },
    { path: '', redirectTo: '', pathMatch: 'full' },
]

@NgModule({
    imports: [RouterModule.forRoot(routes)],
    exports: [RouterModule],
})
export class AppRoutingModule {}
