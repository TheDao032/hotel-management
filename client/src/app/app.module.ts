import { NgModule } from '@angular/core'
import { BrowserModule } from '@angular/platform-browser'
import { BrowserAnimationsModule } from '@angular/platform-browser/animations'
import { HttpClientModule } from '@angular/common/http'

import { AppRoutingModule } from './app.routes'

import { httpInterceptorProviders } from './http-interceptors/index'
import { AppComponent } from './app.component'
import { LoginComponent } from './login/login.component'
import { UnSupportedBrowserComponent } from './un-supported-browser/un-supported-browser.component'
import { ZXingScannerModule } from '@zxing/ngx-scanner'
import { FullCalendarModule } from '@fullcalendar/angular'
import { FormsModule } from '@angular/forms'
import { CommonModule } from '@angular/common'
//import { JwPaginationComponent } from 'jw-angular-pagination';
@NgModule({
    declarations: [AppComponent, LoginComponent, UnSupportedBrowserComponent],
    imports: [BrowserModule, BrowserAnimationsModule, HttpClientModule, AppRoutingModule, ZXingScannerModule, FullCalendarModule, FormsModule, CommonModule],
    exports: [],
    entryComponents: [],
    providers: [httpInterceptorProviders],
    bootstrap: [AppComponent],
})
export class AppModule {}
