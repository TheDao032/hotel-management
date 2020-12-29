import { Component, OnInit, ElementRef, ViewChild, AfterViewInit } from '@angular/core'
import { MatSnackBar, MatDialog } from '@angular/material'

import { EmployeeHistoryDialogComponent } from './employee-history-dialog'
import { SharedService } from '@app/shared/shared.service'
import { EmployeeHistoryService } from './employee-history.service'
import { fn } from '@app/common'
import * as common from '@app/common'

@Component({
    selector: 'app-employee-history',
    templateUrl: './employee-history.component.html',
    styleUrls: ['./employee-history.component.scss'],
    providers: [EmployeeHistoryService],
})
export class EmployeeHistoryComponent implements OnInit, AfterViewInit {
    @ViewChild('fileimport', { static: false }) fileimport: ElementRef
    uploadMessage = ''
    modalTitle = ''
    myFile: File
    modalAttr = ''
    invalidFileMessage = ''
    fileName = ''
    kiList = [{ ki: fn.getKi(), year: fn.getFiscalYear() }]
    soshiki = { honbu: [], bumon: [], group: [] }
    honbuList = []
    bumonList = []
    groupList = []
    data = []
    searchParams: any = {
        shain_cd: '',
        shain_mei: '',
        honbu_cd: '',
        bumon_cd: '',
        group_cd: '',
        ki: '000',
    }

    downloadParams
    currentYear
    shainList: any
    shainErrorMessage: String = ''
    checkShain_cd: Boolean = false
    loading: Boolean
    emptyMessage: String = common.message.W029

    @ViewChild('sf', { read: ElementRef, static: true }) sf: ElementRef
    scrollH = '300px'

    constructor(private sharedService: SharedService, private employeeService: EmployeeHistoryService, private dialog: MatDialog, public snackBar: MatSnackBar) {
        sharedService.setTitle('受講履歴 (社員別)')
        this.sharedService.getKiList().subscribe((res) => {
            this.kiList = res
            this.changeYear()
        })
    }

    async ngOnInit() {
        this.loading = true
        const lastFormData = this.sharedService.getFormDataSaved('employee')
        if (lastFormData) {
            this.searchParams = lastFormData.formDataSaved
            //this.data = lastFormData.dataSaved
        }
        this.getKiList().then(
            (success: any) => {
                this.kiList = success
                this.changeYear()
                this.shainErrorMessage = ''
                this.changeSoshiki()
                this.onSearch()
                $('#fakeBrowseFileImport, #fakeFileImport').on('click', () => {
                    $('#file').trigger('click')
                })
            },
            (error) => {
                this.kiList = []
            }
        )
    }

    ngOnDestroy(): void {
        this.snackBar.dismiss()
    }

    getKiList() {
        return new Promise((resolve, reject) => {
            this.sharedService.getKiList().subscribe(
                (res) => {
                    resolve(res)
                },
                (err) => {
                    reject()
                }
            )
        })
    }

    ngAfterViewInit() {
        setTimeout(() => {
            this.setHeight()
        }, 1000)
    }

    setHeight() {
        const wh = document.getElementsByClassName('app-content')[0].clientHeight
        const sfh = this.sf.nativeElement.clientHeight
        const tbHeight = wh - 48 - sfh - 36
        this.scrollH = tbHeight + 'px'
    }

    changeYear() {
        this.sharedService.getSoshiki({ ki: -1 }).subscribe((res) => {
            this.soshiki = res.data.soshiki
            this.changeSoshiki()
        })
    }

    changeSoshiki() {
        this.honbuList = this.soshiki.honbu
        this.bumonList = this.soshiki.bumon.filter((item) => !this.searchParams.honbu_cd || this.searchParams.honbu_cd == item.honbu_cd)
        this.groupList = this.soshiki.group.filter((item) => (!this.searchParams.honbu_cd || this.searchParams.honbu_cd == item.honbu_cd) && (!this.searchParams.bumon_cd || this.searchParams.bumon_cd == item.bumon_cd))
    }

    openDialog(injectTitle, injectMessage, hasError = false) {
        const dialogRef = this.dialog.open(EmployeeHistoryDialogComponent, {
            data: {
                title: injectTitle,
                message: injectMessage,
            },
        })

        dialogRef.afterClosed().subscribe((info) => {
            if (!info || hasError) {
                return
            }
            if (info) {
                this.importFile()
            }
        })
    }

    onChangeShainCd(newValue) {
        this.shainErrorMessage = ''
        this.checkShain_cd = false
    }

    formReset() {
        this.searchParams = {
            shain_cd: '',
            shain_mei: '',
            honbu_cd: '',
            bumon_cd: '',
            group_cd: '',
            ki: '000',
        }
        this.sharedService.setFormDataSaved('employee', this.searchParams, this.data)
        this.shainErrorMessage = ''
        this.changeSoshiki()
        this.onSearch()
    }

    download() {
        this.employeeService.download(this.downloadParams)
    }

    async onSearch() {
        this.shainList = []
        const patt = /^\d*$/i
        if (this.searchParams.shain_cd && patt.test(this.searchParams.shain_cd) === false) {
            this.shainErrorMessage = common.message.W012({ param: '社員番号' })
            this.checkShain_cd = true
            return
        }
        if (this.searchParams.ki !== '000') {
            this.employeeService.searchEmployee(this.searchParams).subscribe(
                (res) => {
                    this.sharedService.setFormDataSaved('employee', this.searchParams, res.data)
                    this.shainList = res.data
                },
                (err) => {
                    this.loading = false
                },
                () => {
                    this.downloadParams = { ...this.searchParams }
                    this.loading = false
                }
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
            const result = await this.searchEmployeeOfKi(searchParams)
            if (result.code === 0) {
                allShain = allShain.concat(result.data)
                continue
            }
            success = false
            break
        }
        if (success) {
            this.downloadParams = { ...this.searchParams }
            this.sharedService.setFormDataSaved('employee', this.searchParams, this.data)
            this.shainList = allShain
            this.snackBar.dismiss()
            return
        }
        this.snackBar.open('Error')
        setTimeout(() => {
            this.snackBar.dismiss()
        }, 3000)
    }

    searchEmployeeOfKi(searchParams): any {
        return new Promise((resolve, reject) => {
            this.employeeService.searchEmployee(searchParams).subscribe(
                (res) => {
                    const success = {
                        code: 0,
                        data: res.data,
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

    selectFile(fileList: any, confirmFile = false) {
        this.invalidFileMessage = ''
        this.myFile = fileList[0]
        if (!this.myFile) {
            return (this.invalidFileMessage = common.message.FL003)
        }
        if (confirmFile) {
            this.openDialog('確認', common.message.W028({ file_name: this.myFile.name }))
        }
    }

    resetUploadForm() {
        this.modalAttr = ''
        this.fileimport.nativeElement.value = ''
        this.myFile = null
        this.fileName = ''
    }

    openSnackBar(text) {
        this.snackBar.open(text)
        setTimeout(() => this.snackBar.dismiss(), 3000)
    }

    importFile() {
        const _formData = new FormData()
        _formData.append('ki', this.searchParams.ki)
        _formData.append('fileupload', this.myFile, this.myFile.name)
        const requestdata = _formData
        this.employeeService.importFile(requestdata).subscribe(
            (res) => {
                this.resetUploadForm()
                this.openSnackBar(common.message.FL001)
                this.onSearch()
            },
            (err) => {
                this.resetUploadForm()
                this.openDialog('通知', common.message.FL002, true)
            }
        )
    }
}
