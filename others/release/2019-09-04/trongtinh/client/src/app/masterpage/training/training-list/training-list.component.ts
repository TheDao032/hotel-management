import { Component, OnInit, OnDestroy, ChangeDetectorRef, ViewChild, ElementRef, AfterViewInit } from '@angular/core'
import { ActivatedRoute } from '@angular/router'
import { MediaMatcher } from '@angular/cdk/layout'
import * as moment from 'moment'

import common from '@app/common'
import { SharedService } from '@app/shared/shared.service'
import { TrainingListService } from './training-list.service'
import { NitteiModel } from '../../../models/nittei'
//import { TagsService } from '../training-info/tags/tags.service'

@Component({
    selector: 'app-training-list',
    templateUrl: './training-list.component.html',
    styleUrls: ['./training-list.component.scss'],
    providers: [TrainingListService],
})
export class TrainingListComponent implements OnInit, OnDestroy, AfterViewInit {
    mobileQuery: MediaQueryList
    private _mobileQueryListener: () => void
    @ViewChild('sf', { read: ElementRef, static: false }) sf: ElementRef
    scrollH = '300px'
    kiList = []
    endDate: any
    previousFormData
    calendarErrorMessage: string
    taishoshaList = []
    taishoshaLevelList = []
    data: any = []
    tema_category: any[] = []
    shukankikanList = []
    formData = {
        ki: '000',
        kensyuu: '',
        kensyuu_category: '-1',
        shukankikan: '-1',
        taishosha_level: '-1',
        taishosha: '-1',
        //Remove By TheDao
        // skills: [],
        holding_date_from: null,
        holding_date_to: null,
        location: [],
        tema_category: '-1',
    }
    loading = true
    most_popular_tag: any

    constructor(changeDetectorRef: ChangeDetectorRef, media: MediaMatcher, private trainingListService: TrainingListService, private sharedService: SharedService, private route: ActivatedRoute) {
        this.kiList = [{ ki: common.fn.getKi(), year: common.fn.getFiscalYear() }]
        // set title
        this.sharedService.setTitle(`研修一覧`)
        // subscription
        this.mobileQuery = media.matchMedia('(max-width: 599px)')
        this._mobileQueryListener = () => changeDetectorRef.detectChanges()
        this.mobileQuery.addEventListener('change', this._mobileQueryListener)
    }

    ngOnInit() {
        this.sharedService.get_all_tema_category({ dependOnKi: false }).subscribe((res) => {
            this.tema_category = res.metaCode === 500 ? [] : res.data
        })
        const ts = this.route.snapshot.params.ts
        const from_date = (ts && new Date(ts - 0)) || new Date(new Date().toDateString())

        const currentMonth = from_date.getMonth()
        const currentYear = from_date.getFullYear()
        // this.endDate = (currentMonth < 3 ? currentYear : currentYear + 1) + '/03/31'
        const momentFromDate = moment(from_date)
        this.endDate = moment([currentYear, currentMonth, momentFromDate.daysInMonth()])
            .add('2', 'M')
            .format('YYYY-MM-DD')

        this.formData.holding_date_from = from_date
        this.formData.holding_date_to = new Date(this.endDate)

        this.previousFormData = this.formData
        const lastFormSaved = this.sharedService.getFormDataSaved('training-list')
        if (lastFormSaved) {
            this.formData = lastFormSaved.formDataSaved
            //(this.data = lastFormSaved.data)
        }

        this.sharedService.getAllShukankikan({ dependOnShain: false }).subscribe((res) => {
            this.shukankikanList = res.data
        })
        this.trainingListService.search_trainning(this.formData).subscribe((res) => {
            this.data = res.data.map((i) => new NitteiModel(i))
            this.loading = false
        })
        this.sharedService.getKiList().subscribe((res) => (this.kiList = res))
        this.sharedService.get_taishosha({ dependOnShain: false }).subscribe((res) => {
            this.taishoshaList = res.data
        })
        this.sharedService.get_taishosha_level({ dependOnShain: false }).subscribe((res) => {
            this.taishoshaLevelList = res.data
        })
        // this.tagsService.getMostPopularTag().subscribe((res) => {
        //     this.most_popular_tag = res.data
        // })
    }

    ngAfterViewInit() {
        setTimeout(() => {
            this.setHeight()
        }, 1000)
    }

    ngOnDestroy() {
        this.mobileQuery.removeEventListener('change', this._mobileQueryListener)
    }

    setHeight() {
        const wh = document.getElementsByClassName('app-content')[0].clientHeight
        const sfh = this.sf.nativeElement.clientHeight
        const tbHeight = wh - 48 - sfh - 70
        this.scrollH = tbHeight + 'px'
    }

    downloadList() {
        if (this.data.length === 0) {
            return this.trainingListService.displaySnackBar('データがありません')
        }
        this.trainingListService.export(this.previousFormData)
    }

    resetForm() {
        this.formData = {
            ki: '000',
            kensyuu: '',
            kensyuu_category: '-1',
            shukankikan: '-1',
            taishosha_level: '-1',
            taishosha: '-1',
            //Remove By TheDao
            // skills: [],
            holding_date_from: null,
            holding_date_to: null,
            location: [],
            tema_category: '-1',
        }
        this.previousFormData = { ...this.formData }
        this.search()
    }
    changeCheckList(e, arr) {
        return (e.checked && arr.indexOf(e.source.value) === -1 && arr.push(e.source.value)) || (!e.checked && arr.indexOf(e.source.value) !== -1 && arr.splice(arr.indexOf(e.source.value), 1))
    }

    isValidCalendar() {
        const isValid = this.formData.holding_date_to === null || this.formData.holding_date_from === null || new Date(this.formData.holding_date_from).valueOf() <= new Date(this.formData.holding_date_to).valueOf()
        this.calendarErrorMessage = (!isValid && common.message.W014) || ''
        return isValid
    }

    search() {
        if (!this.isValidCalendar()) {
            return
        }
        this.data = []
        this.loading = true
        this.trainingListService.search_trainning(this.formData).subscribe(
            (res) => {
                this.sharedService.setFormDataSaved('training-list', this.formData, this.data)
                this.data = res.data.map((i) => new NitteiModel(i))
                this.previousFormData = { ...this.formData }
                // this.taishoshaList = res.data
                //    .map((i) => i.taishosha)
                //    .filter((v, i, arr) => arr.indexOf(v) === i)
                //    .sort()
                // this.taishoshaLevelList = res.data
                //    .map((i) => i.taishosha_level)
                //    .filter((v, i, arr) => arr.indexOf(v) === i)
                //    .sort()
                this.setHeight()
            },
            (_) => (this.loading = false),
            () => (this.loading = false)
        )
    }
}
