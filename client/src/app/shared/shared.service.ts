import { Injectable } from '@angular/core'
import { HttpClient } from '@angular/common/http'
import { of, Observable, Subject } from 'rxjs'
import { map } from 'rxjs/operators'

import { environment } from '@env/environment'
import { fn } from '@app/common'

@Injectable({
    providedIn: 'root',
})
export class SharedService {
    public static instance = null
    private missionAnnouncedSource = new Subject<string>()
    private savingSearchTime = 1
    title = this.missionAnnouncedSource.asObservable()
    /*
        - Lưu các dữ liệu sau khi search ở mỗi trang trùng với id:
    */
    private formDataSavedList = [
        {
            id: 'home',
            created_at: null,
            formDataSaved: {
                name: '',
                status: '',
                mail_address: '',
                begin_date: '',
                expired_date: '',
            },
        },
    ]
    private api = environment.apiUrl
    public soshiki = []
    public kiList = []

    constructor(private http: HttpClient) {}
    /*
        - Hàm set dữ liệu lưu lại
    */
    setFormDataSaved(id, formDataSaved, dataSaved) {
        this.formDataSavedList.map((e) => {
            if (e.id === id) {
                const now = Date.now()
                e.created_at = now
                e.formDataSaved = formDataSaved
                return {
                    ...e,
                }
            }

            return e
        })
    }
    /*
        - Hàm load dữ liệu sau khi được search với khoảng thời gian được lấy từ cột saving_search_time của postgre
    */
    getFormDataSaved(id): any {
        const data = this.formDataSavedList.find((e) => {
            return e.id === id
        })
        if (data.created_at === null) {
            return null
        }
        if (data) {
            const now1 = Date.now()
            if (now1 - data.created_at < this.savingSearchTime * 60 * 1000) {
                return {
                    formDataSaved: data.formDataSaved,
                }
            }

            return null
        }
    }

    setSavingSearchTime(newTime) {
        this.savingSearchTime = newTime
    }

    getSavingSearchTime() {
        return this.savingSearchTime
    }

    setTitle(title: string) {
        this.missionAnnouncedSource.next(title)
    }

    confirm(message?: string): Observable<boolean> {
        const confirmation = window.confirm(message || 'Is it OK?')
        return of(confirmation)
    }

    public getSoshiki(params = {}) {
        if (this.soshiki.length !== 0) {
            return of(this.soshiki)
        }
        return this.http.post<any>(`${this.api}/common/soshiki`, params)
    }

    public getKiList() {
        if (this.soshiki.length !== 0) {
            return of(this.soshiki)
        }
        return this.http.get<any>(`${this.api}/common/ki-list`).pipe(
            map((res) => {
                this.kiList = res.data
                    .map((item) =>
                        Object.assign({}, item, {
                            year: fn.ki2FiscalYear(item.ki),
                        })
                    )
                    .sort((a, b) => Number(b.ki) - Number(a.ki))
                return this.kiList
            })
        )
    }
    isMobile() {
        return typeof window.orientation !== 'undefined' || navigator.userAgent.indexOf('IEMobile') !== -1
    }
    public getAllShukankikan(dependOn): Observable<any> {
        return this.http.post<any>(`${environment.apiUrl}/common/get-shukankikan-list`, dependOn)
    }

    public get_all_tema_category(dependOn): Observable<any> {
        return this.http.post(this.api + '/common/tema-category', dependOn)
    }
    // UPDATED BY GIANG
    public get_tema_category_by_id(id): Observable<any> {
        return this.http.post(this.api + `/common/get-child-tema-category-by-id/${id}`, {})
    }
    public get_list_tema_category() {
        return this.http.get<any>(this.api + '/common/list-tema-category')
    }
    // END UPDATE
    public get_list_child_tema_category() {
        return this.http.get<any>(`${this.api}/common/list-child-tema-category`)
    }
    public get_taishosha(dependOn): Observable<any> {
        return this.http.post(this.api + '/common/get-taishosha-list', dependOn)
    }
    public get_taishosha_level(dependOn): Observable<any> {
        return this.http.post(this.api + '/common/get-taishosha-level-list', dependOn)
    }
    // Update By TheDao
    public get_user_login_info() {
        return this.http.get<any>(this.api + '/kensyuu/master/user-login-info')
    }
    public get_user_work_time(ki) {
        return this.http.post<any>(this.api + '/kensyuu/master/work-time', { ki })
    }
}
