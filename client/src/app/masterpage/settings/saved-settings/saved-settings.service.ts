import { Injectable } from '@angular/core';
import { environment } from '@env/environment'
import { HttpClient } from '@angular/common/http'

@Injectable({
  providedIn: 'root'
})
export class SavedSettingsService {
    private api = environment.apiUrl
    constructor(private http: HttpClient) { }
    updateTimeSearch(time) {
        return this.http.post<any>(this.api + '/settings/update-time-search',
            { time }
        )
    }
    getDetailTimeSearch(data) {

        return this.http.post<any>(this.api + '/settings/get-detail-time-search',
            { data }
        )
    }
}
