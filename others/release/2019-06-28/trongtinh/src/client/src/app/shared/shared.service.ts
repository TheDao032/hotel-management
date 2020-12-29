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
    private savingSearchTime
    title = this.missionAnnouncedSource.asObservable()
    private formDataSavedList = [
        {
            id: 'training-apply-list',
            created_at: null,
            formDataSaved: {
                ki: '000',
                honbu_cd: '',
                bumon_cd: '',
                group_cd: '',
                shain_mei: '',
                shain_cd: '',
                kensyuu_mei: '',
                status: '-1',
                kensyuubi_from: null,
                kensyuubi_to: null,
                shukankikan: '-1',
            },
            dataSaved: [],
        },
        {
            id: 'training-approval',
            created_at: null,
            formDataSaved: {
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
            },
            dataSaved: [],
        },
        {
            id: 'training-list',
            created_at: null,
            formDataSaved: {
                ki: '000',
                kensyuu: '',
                kensyuu_category: '-1',
                shukankikan: '-1',
                taishosha_level: '-1',
                taishosha: '-1',
                skills: [],
                holding_date_from: null,
                holding_date_to: null,
                location: [],
                tema_category: '-1',
            },
        },
        {
            id: 'employee',
            created_at: null,
            formDataSaved: {
                shain_cd: '',
                shain_mei: '',
                honbu_cd: '',
                bumon_cd: '',
                group_cd: '',
                ki: '000',
            },
            dataSaved: [],
        },
        {
            id: 'home',
            created_at: null,
            formDataSaved: {
                ki: '000',
                shukankikan: '-1',
                status: '',
                kensyuu_mei: '',
                kensyuubi_from: '',
                kensyuubi_to: '',
            },
        },
    ]
    private api = environment.apiUrl
    public soshiki = []
    public kiList = []

    constructor(private http: HttpClient) {}

    setFormDataSaved(id, formDataSaved, dataSaved) {
        this.formDataSavedList.map((e) => {
            if (e.id === id) {
                const now = Date.now()
                e.created_at = now
                e.formDataSaved = formDataSaved
                e.dataSaved = dataSaved
                return {
                    ...e,
                }
            }

            return e
        })
    }

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
                    dataSaved: data.dataSaved,
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

    public getAllShukankikan(dependOn): Observable<any> {
        return this.http.post<any>(`${environment.apiUrl}/common/get-shukankikan-list`, dependOn)
    }

    public get_all_tema_category(dependOn): Observable<any> {
        return this.http.post(this.api + '/common/tema-category', dependOn)
    }
    public get_taishosha(dependOn): Observable<any> {
        return this.http.post(this.api + '/common/get-taishosha-list', dependOn)
    }
    public get_taishosha_level(dependOn): Observable<any> {
        return this.http.post(this.api + '/common/get-taishosha-level-list', dependOn)
    }
}
