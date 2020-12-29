import { Component, OnInit, OnDestroy, ChangeDetectorRef, ElementRef, ViewChild, AfterViewInit } from '@angular/core'
import { DatePipe } from '@angular/common'
import { MatSnackBar } from '@angular/material'
import { MediaMatcher } from '@angular/cdk/layout'

import { Observable } from 'rxjs'

import common from '@app/common'
import { SharedService } from '@app/shared/shared.service'
import { TrainingApprovalService } from './training-approval.service'
import * as moment from 'moment'

@Component({
    selector: 'app-training-approval',
    templateUrl: './training-approval.component.html',
    styleUrls: ['./training-approval.component.scss'],
    providers: [TrainingApprovalService, DatePipe],
})
export class TrainingApprovalComponent implements OnInit, AfterViewInit, OnDestroy {
    mobileQuery: MediaQueryList
    private _mobileQueryListener: () => void

    kiList = []
    status
    soshiki = { honbu: [], bumon: [], group: [] }
    honbuList = []
    bumonList = []
    groupList = []
    tema_category: any[] = []
    shukankikanList: any[] = []
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
        tema_category: '-1',
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
        tema_category: '-1',
        shukankikan: '-1',
    }

    public intervalDetectChanges: any
    public data: any[] = []
    public loading: Boolean
    public emptyMessage: String = common.message.KS007

    @ViewChild('sf', { read: ElementRef, static: true }) sf: ElementRef
    scrollH = '300px'

    constructor(changeDetectorRef: ChangeDetectorRef, media: MediaMatcher, private dp: DatePipe, private sharedService: SharedService, private trainingApprovalService: TrainingApprovalService, public snackBar: MatSnackBar, private changeRef: ChangeDetectorRef) {
        this.kiList = [{ ki: common.fn.getKi(), year: common.fn.getFiscalYear() }]
        // set title
        this.sharedService.setTitle('研修承認')
        // init static value
        this.status = common.status
        // subscription
        this.mobileQuery = media.matchMedia('(max-width: 599px)')
        this._mobileQueryListener = () => changeDetectorRef.detectChanges()
        this.mobileQuery.addListener(this._mobileQueryListener)

        this.sharedService
            .getSoshiki({ ki: -1 }) //ki: common.fn.getKi()
            .subscribe((res) => {
                this.soshiki = res.data.soshiki
                this.changeSoshiki()
            })
    }

    ngOnInit() {
        this.sharedService.get_all_tema_category({ dependOnKi: false }).subscribe((res) => {
            this.tema_category = res.metaCode === 500 ? [] : res.data
        })
        this.sharedService
            //   .getAllShukankikan(common.fn.getKi())
            .getAllShukankikan({ dependOnShain: false })
            .subscribe((res) => (this.shukankikanList = res.data))
        this.changeRef.detach()
        this.changeRef.detectChanges()
        this.intervalDetectChanges = setInterval(() => this.changeRef.detectChanges(), 500)
        this.sharedService.getKiList().subscribe((res) => {
            this.kiList = res
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
                tema_category: '-1',
                shukankikan: '-1',
            }
            const lastFormData = this.sharedService.getFormDataSaved('training-approval')
            if (lastFormData) {
                this.searchParams = lastFormData.formDataSaved
                // this.data = getDateSaved1.dataSaved
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

    setHeight() {
        const wh = document.getElementsByClassName('app-content')[0].clientHeight
        const sfh = this.sf.nativeElement.clientHeight
        const tbHeight = wh - 48 - sfh - 40
        this.scrollH = tbHeight + 'px'
    }

    changeSoshiki() {
        this.honbuList = this.soshiki.honbu
        this.bumonList = this.soshiki.bumon.filter((item) => !this.searchParams.honbu_cd || this.searchParams.honbu_cd == item.honbu_cd)
        this.groupList = this.soshiki.group.filter((item) => (!this.searchParams.honbu_cd || this.searchParams.honbu_cd == item.honbu_cd) && (!this.searchParams.bumon_cd || this.searchParams.bumon_cd == item.bumon_cd))
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
            tema_category: '-1',
            shukankikan: '-1',
        }

        this.previousSearchParams = { ...this.searchParams }
        this.changeSoshiki()
        this.onSearch()
        this.sharedService.setFormDataSaved('training-approval', this.searchParams, this.data)
    }

    saveStatus(rowStatusUpdate) {
        console.log(rowStatusUpdate)
        this.trainingApprovalService.approvalRequest(rowStatusUpdate).subscribe((response) => {
            if (response.err) {
                alert('There was an error when saving status')
            } else {
                // if (response.isNeedToReloadClient) {
                //     const { data } = response;
                //     this.data = this.data.map(e => {
                //         if (e.kensyuu_id === data.kensyuu_id) {
                //             return {
                //                 ...e,
                //                 status: data.status
                //             };
                //         } else {
                //             return {
                //                 ...e
                //             };
                //         }
                //     });
                // }

                this.snackBar.open('ステータス保存を成功しました。')
                setTimeout(() => this.snackBar.dismiss(), 3000)
                rowStatusUpdate.originalStatus = rowStatusUpdate.status
                if (rowStatusUpdate.status === '3') {
                    this.trainingApprovalService.sendMailAuto(rowStatusUpdate).subscribe(() => {})
                }
            }
        })
    }

    download() {
        this.trainingApprovalService.downloadRegisteredList(this.previousSearchParams)
    }

    downloadLeft() {
        if (this.loading) {
            // return
        }
        const dataLeft = this.data.filter((e) => e.shukankikan && e.shukankikan.includes('富士通'))
        this.trainingApprovalService.downloadLeft(dataLeft)
    }

    downloadRight() {
        if (this.loading) {
            //return
        }
        const dataRight = this.data.filter((e) => e.shukankikan && e.shukankikan.includes('トレノケート') && (e.kensyuu_mei.includes('PM-') || e.kensyuu_mei.includes('IS-') || e.kensyuu_mei.includes('BS-')))
        this.trainingApprovalService.downloadRight(dataRight)
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
                    this.sharedService.setFormDataSaved('training-approval', this.searchParams, this.data)
                    this.data = res.data.map((i) => {
                        i.jyukouryou = Number(i.jyukouryou)
                        return { ...i, originalStatus: i.status }
                    })

                    this.previousSearchParams = { ...params }
                    this.changeRef.detectChanges()
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
            this.sharedService.setFormDataSaved('training-approval', this.searchParams, this.data)
            this.data = allShain
            this.snackBar.dismiss()
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
                        i.jyukouryou = Number(i.jyukouryou)
                        return { ...i, originalStatus: i.status }
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

    canDeactivate(): Observable<boolean> | boolean {
        // Allow synchronous navigation (`true`) if no crisis or the crisis is unchanged
        if (this.data.filter((i) => i.status !== i.originalStatus).length === 0) {
            clearInterval(this.intervalDetectChanges)
            return true
        }
        // Otherwise ask the user with the dialog service and return its
        // observable which resolves to true or false when the user decides
        return this.sharedService.confirm(common.message.W025)
    }
}
