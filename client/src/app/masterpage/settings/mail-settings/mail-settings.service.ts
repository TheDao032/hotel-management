import { Injectable } from '@angular/core'
import { HttpClient } from '@angular/common/http'

import { environment } from '@env/environment'

@Injectable({
    providedIn: 'root',
})
export class MailSettingsService {
    private api = environment.apiUrl
    constructor(private http: HttpClient) {}

    dopostContent(kekka) {
        return this.http.post<any>(this.api + '/settings/submit-mail', kekka)
    }

    getMail() {
        return this.http.post<any>(this.api + '/settings/get-mail', {})
    }

    deleteMail(id_mail) {
        return this.http.post<any>(this.api + '/settings/delete-mail', {
            id_mail,
        })
    }

    fetchMailInfo(id_mail) {
        return this.http.post<any>(this.api + '/settings/fetch-mail-info', {
            id_mail,
        })
    }

    sendMail(id_mail) {
        return this.http.post<any>(this.api + '/settings/send-mail', {
            id_mail,
        })
    }
    getDatailMailShukankikan(data) {
        return this.http.post<any>(this.api + '/settings/get-detail-mail-company', {
            data,
        })
    }
    getDetailMail(id) {
        return this.http.post<any>(this.api + '/settings/get-detail-mail', {
            id,
        })
    }

    getDetailFromMail(id = '') {
        return this.http.post<any>(this.api + '/settings/get-detail-from-mail', { id })
    }

    saveMail(data) {
        return this.http.post<any>(this.api + '/settings/save-mail', {
            data,
        })
    }

    getDetailConfig(id) {
        return this.http.post<any>(this.api + '/settings/get-config', { id })
    }

    getDetailTimeSettingMail(data) {
        return this.http.post<any>(this.api + '/settings/get-time-setting-mail', {
            data,
        })
    }

    editMailShukankikhan(data) {
        return this.http.post<any>(this.api + '/settings/edit-mail-shukankikhan', {
            data,
        })
    }
    updateFormMailSetting(data) {
        return this.http.post<any>(this.api + '/settings/update-form-mail-setting', {
            data,
        })
    }
    updateConfigMail(data) {
        return this.http.post<any>(this.api + '/settings/update-config-mail', {
            data,
        })
    }
    updateTemplateFrom(data) {
        return this.http.post<any>(this.api + '/settings/update-template-from', {
            data,
        })
    }
    updateMailShukankikan(data) {
        return this.http.post<any>(this.api + '/settings/update-mail-shukankikan', {
            data,
        })
    }
    updateDaySendMail(data) {
        return this.http.post<any>(this.api + '/settings/update-day-send-mail', {
            data,
        })
    }
    setDefaultMail(input) {
        return this.http.post<any>(this.api + '/settings/set-default-mail', {
            input,
        })
    }
}
