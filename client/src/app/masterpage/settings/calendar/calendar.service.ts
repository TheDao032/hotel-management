import { Injectable } from '@angular/core'
import { environment } from '@env/environment'
import { HttpClient } from '@angular/common/http'
import { map } from 'rxjs/operators'
// const moment = require('moment')
import * as moment from 'moment'

import { toTimeZone } from '@app/common/constant'
@Injectable({
    providedIn: 'root',
})
export class CalendarService {
    private api = environment.apiUrl
    constructor(private http: HttpClient) {}
    evMap = (ev) => {
        const { event_title, all_day, ...event } = ev
        const allDay = !!all_day
        return { ...event, allDay, title: event_title }
    }
    authorizeUser(code) {
        return this.http.post<any>(`${this.api}/authentication/authorize`, { code })
    }

    getCode(input) {
        return this.http.post<any>(`${this.api}/authentication/info`, { input })
    }

    getEventsCalendar(input, nittei_data: any = null) {
        return this.http.post<any>(`${this.api}/settings/get-events`, { input, nittei_data })
    }

    createOrUpdateEvent(input, eventData: any = null, shain: any = null, eventList: any = null, status: any = null) {
        return this.http.post<any>(`${this.api}/settings/create-or-update-event`, { input, eventData, shain, eventList, status })
    }

    deleteEvent(input, eventId: any = '') {
        return this.http.post<any>(`${this.api}/settings/delete-event`, { input, eventId })
    }
    getEventList(data) {
        return this.http.post<any>(`${this.api}/settings/event-list`, data)
    }
    autoAddAllEvent(data) {
        //
        return this.http.post<any>(`${this.api}/settings/all-event`, { data })
    }
    updateSchedule(data) {
        return this.http.post<any>(`${this.api}/settings/update-event`, { data })
    }
    deleteEventID(id) {
        return this.http.post<any>(`${this.api}/settings/delete-event-id`, { id })
    }

    getAvatar(input) {
        return this.http.post<any>(`${this.api}/settings/get-avatar`, { input })
    }
}
