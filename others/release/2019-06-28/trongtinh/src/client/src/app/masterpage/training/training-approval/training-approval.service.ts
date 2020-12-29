import { Injectable } from '@angular/core'
import { HttpClient } from '@angular/common/http'
import { Observable } from 'rxjs'
import { environment } from '@env/environment'
import { saveAs } from 'file-saver/FileSaver'
import { SharedService } from '@app/shared/shared.service'
import { MatSnackBar } from '@angular/material'
@Injectable()
export class TrainingApprovalService {
    private api = environment.apiUrl
    constructor(private http: HttpClient, public snackBar: MatSnackBar) {}

    getRegisteredList(params): Observable<any> {
        return this.http.post<any>(this.api + '/training/get-registered-list', params)
    }

    downloadRegisteredList(params) {
        return this.http.post(this.api + '/export/shonin', params, { responseType: 'blob' }).subscribe((blob) => saveAs(blob, '研修承認.xlsx'))
    }

    downloadLeft(data) {
        return this.http.post(`${this.api}/training/download-left`, { params: { data } }, { responseType: 'blob' }).subscribe((blob) => {
            if (blob.type !== 'application/json') {
                saveAs(blob, '富士通.xlsx')
            } else {
                this.snackBar.open('データが見つかりません')
                setTimeout(() => this.snackBar.dismiss(), 3000)
            }
        })
    }

    downloadRight(data) {
        return this.http.post(`${this.api}/training/download-right`, { params: { data } }, { responseType: 'blob' }).subscribe((blob) => {
            if (blob.type !== 'application/json') {
                saveAs(blob, 'トレノケート.xlsx')
            } else {
                this.snackBar.open('データが見つかりません')
                setTimeout(() => this.snackBar.dismiss(), 3000)
            }
        })
    }

    approvalRequest(params): Observable<any> {
        return this.http.post<any>(this.api + '/training/approval-register', params)
    }
    sendMailAuto(data) {
        return this.http.post<any>(this.api + '/training/send-mail-auto', data)
    }
    // downloadData(data) {
    //   return this.http.post<any>(this.api + '/training/download', data)
    // }
}
