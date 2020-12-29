import { Component, OnInit, OnDestroy, ChangeDetectorRef, AfterViewInit, ViewChild, ElementRef } from '@angular/core'
import { DatePipe } from '@angular/common'
import { MatSnackBar } from '@angular/material'
import { MediaMatcher } from '@angular/cdk/layout'
import * as moment from 'moment'

import { TrainingApprovalService } from '../training-approval/training-approval.service'
import { SharedService } from '@app/shared/shared.service'
import common from '@app/common'
import { fn } from '@angular/compiler/src/output/output_ast'

@Component({
    selector: 'app-training-apply-list',
    templateUrl: './training-apply-list.component.html',
    styleUrls: ['./training-apply-list.component.scss'],
    providers: [TrainingApprovalService, DatePipe],
})
export class TrainingApplyListComponent implements OnInit, OnDestroy, AfterViewInit {
    mobileQuery: MediaQueryList
    private _mobileQueryListener: () => void
    @ViewChild('sf', { read: ElementRef, static: false }) sf: ElementRef
    scrollH = '300px'
    // export class TrainingApprovalComponent implements OnInit {
    status
    soshiki = { honbu: [], bumon: [], group: [] }
    honbuList = []
    bumonList = []
    groupList = []
    shukankikanList = []
    kiList = []
    public previousSearchParams = {
        ki: '000',
        honbu_cd: '',
        bumon_cd: '',
        group_cd: '',
        shain_mei: '',
        shain_cd: '',
        kensyuu_mei: '',
        status: '-1',
        kensyuubi_from: '',
        kensyuubi_to: '',
        shukankikan: '-1',
    }

    public searchParams: any = {
        ki: '000',
        honbu_cd: '',
        bumon_cd: '',
        group_cd: '',
        shain_mei: '',
        shain_cd: '',
        kensyuu_mei: '',
        status: '-1',
        kensyuubi_from: '',
        kensyuubi_to: '',
        shukankikan: '-1',
    }

    public intervalDetectChanges: any
    public data: any[] = []
    public loading: Boolean
    public emptyMessage: String = common.message.KS007
    constructor(changeDetectorRef: ChangeDetectorRef, media: MediaMatcher, private dp: DatePipe, private sharedService: SharedService, private trainingApprovalService: TrainingApprovalService, public snackBar: MatSnackBar) {
        this.kiList = [{ ki: common.fn.getKi(), year: common.fn.getFiscalYear() }]
        // set title
        this.sharedService.setTitle('受講状況確認')
        // set static props
        this.status = common.status
        // subscription
        this.mobileQuery = media.matchMedia('(max-width: 599px)')
        this._mobileQueryListener = () => changeDetectorRef.detectChanges()
        this.mobileQuery.addListener(this._mobileQueryListener)

        this.sharedService.getSoshiki({ ki: common.fn.getKi() }).subscribe((res) => {
            this.soshiki = res.data.soshiki
            this.changeSoshiki()
        })
    }

    ngOnInit() {
        const first = new Date()
        first.setDate(1)
        const momentNext = moment(first).add(2, 'month')
        const next = momentNext.endOf('month')
        this.searchParams = {
            ki: '000',
            honbu_cd: '',
            bumon_cd: '',
            group_cd: '',
            shain_mei: '',
            shain_cd: '',
            kensyuu_mei: '',
            status: '-1',
            kensyuubi_from: first,
            kensyuubi_to: next,
            shukankikan: '-1',
        }

        this.sharedService.getAllShukankikan({ dependOnShain: false }).subscribe((res) => (this.shukankikanList = res.data))
        this.sharedService.getKiList().subscribe((res) => {
            this.kiList = res
            this.changeSoshiki()
            const lastFormData = this.sharedService.getFormDataSaved('training-apply-list')
            if (lastFormData) {
                this.searchParams = lastFormData.formDataSaved
                //(this.data = lastFormData.data)
            }
            this.onSearch()
        })
    }

    ngAfterViewInit() {
        setTimeout(() => {
            this.setHeight()
        }, 1000)
    }

    ngOnDestroy() {
        this.mobileQuery.removeListener(this._mobileQueryListener)
        this.snackBar.dismiss()
    }

    openSnackBar() {
        this.snackBar.open('ステータス保存を成功しました。')
        setTimeout(() => this.snackBar.dismiss(), 3000)
    }

    setHeight() {
        const appcontentHeight = document.getElementsByClassName('app-content')[0].clientHeight
        const sfh = this.sf.nativeElement.clientHeight
        const tblHeight = appcontentHeight - 48 - sfh - 36
        this.scrollH = tblHeight + 'px'
    }

    changeSoshiki() {
        this.honbuList = this.soshiki.honbu
        this.bumonList = this.soshiki.bumon.filter((item) => !this.searchParams.honbu_cd || this.searchParams.honbu_cd === item.honbu_cd)
        this.groupList = this.soshiki.group.filter((item) => (!this.searchParams.honbu_cd || this.searchParams.honbu_cd === item.honbu_cd) && (!this.searchParams.bumon_cd || this.searchParams.bumon_cd === item.bumon_cd))
    }

    formReset() {
        this.searchParams = {
            ki: '000',
            honbu_cd: '',
            bumon_cd: '',
            group_cd: '',
            shain_mei: '',
            shain_cd: '',
            kensyuu_mei: '',
            status: '-1',
            kensyuubi_from: '',
            kensyuubi_to: '',
            shukankikan: '-1',
        }
        this.sharedService.setFormDataSaved('training-apply-list', this.searchParams, this.data)
        this.previousSearchParams = { ...this.searchParams }
        this.onSearch()
    }

    download() {
        console.log(this.previousSearchParams)
        this.trainingApprovalService.downloadRegisteredList(this.previousSearchParams)
    }

    async onSearch() {
        this.data = []
        this.loading = true

        const { kensyuubi_from, kensyuubi_to, ...params } = this.searchParams
        params.kensyuubi_from = (kensyuubi_from && this.dp.transform(new Date(kensyuubi_from), 'yyyy-MM-dd')) || ''
        params.kensyuubi_to = (kensyuubi_to && this.dp.transform(new Date(kensyuubi_to), 'yyyy-MM-dd')) || ''

        if (this.searchParams.ki !== '000') {
            this.trainingApprovalService.getRegisteredList(params).subscribe(
                (res) => {
                    this.sharedService.setFormDataSaved('training-apply-list', this.searchParams, this.data)
                    this.data = res.data.map((i) => {
                        const jyukouryou = Number(i.jyukouryou)
                        const status = Number(i.status)
                        const status_name = this.status.getName(i.status)
                        return {
                            ...i,
                            jyukouryou,
                            status,
                            status_name,
                            originalStatus: status,
                        }
                    })
                    this.previousSearchParams = { ...params }
                },
                (_) => (this.loading = false),
                () => (this.loading = false)
            )

            return
        }

        this.snackBar.open('データを読み込んでいます。')
        let success = true
        let allShain = []
        for (const ki of this.kiList) {
            const searchParams = {
                ...this.searchParams,
                ki: ki.ki,
            }
            const result = await this.searchRegisteredListOfKi(searchParams)

            if (result.code === 0) {
                allShain = allShain.concat(result.data)
                continue
            }
            success = false
            break
        }
        if (success) {
            this.data = allShain
            this.snackBar.dismiss()
            this.sharedService.setFormDataSaved('training-apply-list', this.searchParams, this.data)
            this.previousSearchParams = { ...params }
            return
        }
        this.snackBar.open('Error')
        setTimeout(() => {
            this.snackBar.dismiss()
        }, 3000)
    }

    searchRegisteredListOfKi(searchParams): any {
        return new Promise((resolve, reject) => {
            this.trainingApprovalService.getRegisteredList(searchParams).subscribe(
                (res) => {
                    const eachData = res.data.map((i) => {
                        const jyukouryou = Number(i.jyukouryou)
                        const status = Number(i.status)
                        const status_name = this.status.getName(i.status)
                        return {
                            ...i,
                            jyukouryou,
                            status,
                            status_name,
                            originalStatus: status,
                        }
                    })

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
}
