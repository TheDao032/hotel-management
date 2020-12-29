import { Injectable } from '@angular/core'
import { HttpClient } from '@angular/common/http'
import { Observable } from 'rxjs'

import { environment } from '@env/environment'

@Injectable()
export class homePageService {
    constructor(private http: HttpClient) {}
    // get all tsuuchi by shain_cd
    getAllTsuuchi(): Observable<any> {
        return this.http.post<any>(
            `${environment.apiUrl}/mypage/all-tsuuchi`,
            {}
        )
    }

    searchKensyuu(params): Observable<any> {
        return this.http.post<any>(
            `${environment.apiUrl}/mypage/search-kensyuu`,
            params
        )
    }
}
