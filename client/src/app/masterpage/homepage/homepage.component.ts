import {
    Component,
    OnInit,
    OnDestroy,
    ChangeDetectorRef,
    ElementRef,
    ViewChild,
    AfterViewInit,
} from '@angular/core'
import { Router } from '@angular/router'
import { MediaMatcher } from '@angular/cdk/layout'

import { Subscription } from 'rxjs'

import { AuthService } from '@app/auth/auth.service'
import { homePageService } from './homepage.service'
import { fn, status } from '@app/common'
import { MatSnackBar } from '@angular/material'
import { SharedService } from './../../shared/shared.service'

@Component({
    selector: 'app-homepage',
    templateUrl: './homepage.component.html',
    styleUrls: ['./homepage.component.scss'],
    providers: [homePageService],
})
export class homePageComponent implements OnInit, OnDestroy, AfterViewInit {
    userSubsrciption: Subscription
    mobileQuery: MediaQueryList
    private _mobileQueryListener: () => void
    public sharedService: SharedService

    // shukankikanLinkList = [
    //   { text: '（株）富士通ラーニングメディア', url: 'https://www.kcc.knowledgewing.com/FLM/login/init-login'},
    //   { text: '（株）ナレッジトラスト', url: 'http://pheasant.cube.cubesystem.co.jp/procenter/m.do?i=467956'},
    //   { text: 'トレノケート（株）', url: 'http://pheasant.cube.cubesystem.co.jp/procenter/m.do?i=467957'},
    // ]
    shukankikanToLinkList = {
        '（株）富士通ラーニングメディア':
            'https://www.kcc.knowledgewing.com/FLM/login/init-login',
        '（株）ナレッジトラスト':
            'http://pheasant.cube.cubesystem.co.jp/procenter/m.do?i=467956',
        'トレノケート（株）':
            'http://pheasant.cube.cubesystem.co.jp/procenter/m.do?i=467957',
    }

    status
    data = []
    formData = {
        // ki: fn.getKi(),
        name: '',
        status: '',
        mail_address: '',
        begin_date: '',
        expired_date: '',
    } // sort data input
    eventsStart = []
    eventsEnd = []
    loading = false
    permission_cd = null

    @ViewChild('sf', { read: ElementRef, static: true }) sf: ElementRef
    scrollH = '300px'

    constructor(
        changeDetectorRef: ChangeDetectorRef,
        media: MediaMatcher,
        private auth: AuthService,
        private router: Router,
        private homePageSevice: homePageService,
        public snackBar: MatSnackBar
    ) {
        // set title
        // init static value
        this.status = status
        // subscription
        this.userSubsrciption = this.auth.user.subscribe(
            ({ permission_cd }) => (this.permission_cd = permission_cd)
        )
        this.mobileQuery = media.matchMedia('(max-width: 599px)')
        this._mobileQueryListener = () => changeDetectorRef.detectChanges()
        this.mobileQuery.addListener(this._mobileQueryListener)
    }

    ngOnInit() {
    }

    ngAfterViewInit() {
        setTimeout(() => {
            this.setHeight()
        }, 1000)
    }

    ngOnDestroy() {
        this.mobileQuery.removeListener(this._mobileQueryListener)
        this.userSubsrciption.unsubscribe()
        this.snackBar.dismiss()
    }

    setHeight() {
        const wh = document.getElementsByClassName('app-content')[0]
            .clientHeight
        const sfh = this.sf.nativeElement.clientHeight
        const tbHeight = wh - 48 - sfh - 36
        this.scrollH = `${tbHeight}px`
    }
}
