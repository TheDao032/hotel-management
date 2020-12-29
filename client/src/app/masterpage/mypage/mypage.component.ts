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
import { MypageService } from './mypage.service'
import { SharedService } from '@app/shared/shared.service'
import { fn, status } from '@app/common'
import { NitteiModel } from '../../models/nittei'
import { MatSnackBar } from '@angular/material'

@Component({
    selector: 'app-mypage',
    templateUrl: './mypage.component.html',
    styleUrls: ['./mypage.component.scss'],
    providers: [MypageService],
})
export class MypageComponent implements OnInit, OnDestroy, AfterViewInit {
    userSubsrciption: Subscription
    mobileQuery: MediaQueryList
    private _mobileQueryListener: () => void

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

    kiList
    status
    data = []
    kensyuuList = []
    tsuuchiList = []
    shukankikanList = []
    formData = {
        // ki: fn.getKi(),
        ki: '000',
        shukankikan: '-1',
        status: '',
        kensyuu_mei: '',
        kensyuubi_from: '',
        kensyuubi_to: '',
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
        private mypageSevice: MypageService,
        private sharedService: SharedService,
        public snackBar: MatSnackBar
    ) {
        // set title
        this.sharedService.setTitle('ホーム')
        // init static value
        this.kiList = [{ ki: fn.getKi(), year: fn.getFiscalYear() }]
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
        $('#datepicker').datepicker({
            onSelect: function(date) {
                const v = new Date(date).valueOf()
                this.router.navigate([`training/list/${v}`])
            }.bind(this),
            beforeShowDay: function(date) {
                let result = [true, '', null]
                const matchingStart = $.grep(this.eventsStart, (event) => {
                    return (
                        event.Date.getFullYear() === date.getFullYear() &&
                        event.Date.getMonth() === date.getMonth() &&
                        event.Date.getDate() === date.getDate()
                    )
                })
                if (matchingStart.length) {
                    result = [true, 'highlight-start', '']
                }
                const matchingEnd = $.grep(this.eventsEnd, (event) => {
                    return event.Date.valueOf() === date.valueOf()
                })
                if (matchingEnd.length) {
                    result = [true, 'highlight-end', '']
                }
                return result
            }.bind(this),
        })

        const lastFormData = this.sharedService.getFormDataSaved('home')
        if (lastFormData) {
            this.formData = lastFormData.formDataSaved
            //this.data = lastFormDate.data
        }

        this.sharedService.getKiList().subscribe((res) => {
            this.kiList = res
            this.search()
        })
        this.mypageSevice
            .getAllTsuuchi()
            .subscribe((res) => (this.tsuuchiList = res.data))
        this.sharedService
            .getAllShukankikan({ dependOnShain: true })
            .subscribe((res) => (this.shukankikanList = res.data))
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

    isValidCalendar() {
        const success =
            this.formData.kensyuubi_to === '' ||
            this.formData.kensyuubi_from === '' ||
            new Date(this.formData.kensyuubi_from).valueOf() <=
                new Date(this.formData.kensyuubi_to).valueOf()
        return success
    }

    async search() {
        if (!this.isValidCalendar()) {
            return
        }
        this.kensyuuList = []
        this.eventsStart = []
        this.loading = true

        if (this.formData.ki !== '000') {
            this.mypageSevice.searchKensyuu(this.formData).subscribe(
                (res) => {
                    this.sharedService.setFormDataSaved(
                        'home',
                        this.formData,
                        this.data
                    )
                    this.kensyuuList = res.data
                        .filter((i) => i.status !== 11)
                        .map((i) =>
                            Object.assign(new NitteiModel(i), {
                                moushikomi_id: i.moushikomi_id,
                            })
                        )
                },
                (_) => (this.loading = false),
                () => {
                    this.loading = false
                    this.eventsStart = this.kensyuuList
                        .filter((item) => item.nittei_from && item.status !== 8)
                        .map((item) => ({
                            Title: item.kensyuu_mei,
                            Date: new Date(item.nittei_from),
                            link: '',
                        }))
                    this.eventsEnd = []
                    $('#datepicker').datepicker('refresh')
                }
            )
            return
        }

        this.snackBar.open('データを読み込んでいます。')
        let success = true
        let allShain = []
        for (const ki of this.kiList) {
            const searchParams = {
                ...this.formData,
                ki: ki.ki,
            }
            const result = await this.searchKensyuu(searchParams)
            if (result.code === 0) {
                allShain = allShain.concat(result.data)
                continue
            }
            success = false
            break
        }
        if (success) {
            this.sharedService.setFormDataSaved(
                'home',
                this.formData,
                this.data
            )
            this.kensyuuList = allShain
            this.loading = false
            this.eventsStart = this.kensyuuList
                .filter((item) => item.nittei_from && item.status !== 8)
                .map((item) => ({
                    Title: item.kensyuu_mei,
                    Date: new Date(item.nittei_from),
                    link: '',
                }))
            this.eventsEnd = []
            $('#datepicker').datepicker('refresh')
            this.snackBar.dismiss()
            return
        }
        this.snackBar.open('Error')
        setTimeout(() => {
            this.snackBar.dismiss()
        }, 3000)
    }

    searchKensyuu(searchParams): any {
        return new Promise((resolve, reject) => {
            this.mypageSevice.searchKensyuu(searchParams).subscribe(
                (res) => {
                    const eachData = res.data
                        .filter((i) => i.status !== 11)
                        .map((i) =>
                            Object.assign(new NitteiModel(i), {
                                moushikomi_id: i.moushikomi_id,
                            })
                        )

                    const success = {
                        code: 0,
                        data: eachData,
                    }
                    resolve(success)
                },
                () => {
                    const error = {
                        code: 1,
                        data: [],
                    }
                    reject(error)
                }
            )
        })
    }

    doAnketto(item) {
        // if (this.permission_cd === '99' || this.permission_cd === '70') {
        //   this.router.navigate(['/import/anketto'])
        //   return
        // }
        this.router.navigate([`/survey/${item.moushikomi_id}`])
        // this.router.navigate(['/import/anketto'])
    }
}
