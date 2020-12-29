import { Injectable } from '@angular/core'
import { environment } from '@env/environment'
import { HttpClient } from '@angular/common/http'

@Injectable({
    providedIn: 'root',
})
export class RecommendSettingsService {
    private api = environment.apiUrl
    constructor(private http: HttpClient) {}

    updateRecommend(array) {
        return this.http.post<any>(this.api + '/settings/update-recommends', array)
    }
    getRecommends() {
        return this.http.get<any>(this.api + '/settings/get-recommends')
    }
}
