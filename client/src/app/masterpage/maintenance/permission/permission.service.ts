import { Injectable } from '@angular/core'
import { environment } from '@env/environment'
import { HttpClient } from '@angular/common/http'

@Injectable()
export class PermissionService {
    private api = environment.apiUrl

    constructor(private http: HttpClient) {}

    getPermissionList(data) {
        return this.http.post<any>(
            this.api + '/maintaince/permission/list',
            data
        )
    }

    createNewPermission(data) {
        return this.http.post<any>(
            this.api + '/maintaince/permission/add',
            data
        )
    }

    updatePermission(data) {
        return this.http.post<any>(
            this.api + '/maintaince/permission/update',
            data
        )
    }

    checkShainCdExist(shain_cd) {
        return this.http.post<any>(this.api + '/common/check-shaincd', {
            shain_cd,
        })
    }

    getShainCdList() {
        return this.http.post<any>(this.api + '/common/shain-list', {})
    }

    deletePermission(data) {
        return this.http.post<any>(
            this.api + '/maintaince/permission/delete',
            data
        )
    }
}
