/* global saveAs, Blob, BlobBuilder, console */
/* exported ics */
import { saveAs } from 'file-saver'

export let ics = function(isCancel, shainCd, nitteiId, uidDomain?, prodId?) {
    'use strict'
    let newUidDomain = ''
    let newProdId = ''
    if (navigator.userAgent.indexOf('MSIE') > -1 && navigator.userAgent.indexOf('MSIE 10') === -1) {
        console.log('Unsupported Browser')
        return
    }

    if (typeof uidDomain === 'undefined') {
        newUidDomain = 'default'
    } else newUidDomain = uidDomain
    if (typeof prodId === 'undefined') {
        newProdId = 'Calendar'
    } else newProdId = prodId

    const SEPARATOR = navigator.appVersion.indexOf('Win') !== -1 ? '\r\n' : '\n'
    const calendarEvents = []
    const calendarStart = ['BEGIN:VCALENDAR', `PRODID:${newProdId}`, 'VERSION:2.0'].join(SEPARATOR)
    const calendarEnd = `${SEPARATOR}END:VCALENDAR`
    const BYDAY_VALUES = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA']

    return {
        /**
         * Returns events array
         * @return {array} Events
         */
        events(): any[] {
            return calendarEvents
        },

        /**
         * Returns calendar
         * @return {string} Calendar in iCalendar format
         */
        calendar(): string {
            return calendarStart + SEPARATOR + calendarEvents.join(SEPARATOR) + calendarEnd
        },

        /**
         * Add event to the calendar
         * @param  {string} subject     Subject/Title of event
         * @param  {string} description Description of event
         * @param  {string} location    Location of event
         * @param  {string} begin       Beginning date of event
         * @param  {string} stop        Ending date of event
         */
        addEvent(subject: string, organizer, description: string, location: string, begin: string, stop: string, rrule?) {
            // I'm not in the mood to make these optional... So they are all required
            if (typeof subject === 'undefined' || typeof description === 'undefined' || typeof location === 'undefined' || typeof begin === 'undefined' || typeof stop === 'undefined') {
                return false
            }

            // validate rrule
            if (rrule) {
                if (!rrule.rrule) {
                    if (rrule.freq !== 'YEARLY' && rrule.freq !== 'MONTHLY' && rrule.freq !== 'WEEKLY' && rrule.freq !== 'DAILY') {
                        throw "Recurrence rrule frequency must be provided and be one of the following: 'YEARLY', 'MONTHLY', 'WEEKLY', or 'DAILY'"
                    }

                    if (rrule.until) {
                        if (isNaN(Date.parse(rrule.until))) {
                            throw "Recurrence rrule 'until' must be a valid date string"
                        }
                    }

                    if (rrule.interval) {
                        if (isNaN(parseInt(rrule.interval))) {
                            throw "Recurrence rrule 'interval' must be an integer"
                        }
                    }

                    if (rrule.count) {
                        if (isNaN(parseInt(rrule.count))) {
                            throw "Recurrence rrule 'count' must be an integer"
                        }
                    }

                    if (typeof rrule.byday !== 'undefined') {
                        if (Object.prototype.toString.call(rrule.byday) !== '[object Array]') {
                            throw "Recurrence rrule 'byday' must be an array"
                        }

                        if (rrule.byday.length > 7) {
                            throw "Recurrence rrule 'byday' array must not be longer than the 7 days in a week"
                        }

                        // Filter any possible repeats
                        rrule.byday = rrule.byday.filter((elem, pos) => {
                            return rrule.byday.indexOf(elem) === pos
                        })

                        for (const d in rrule.byday) {
                            if (BYDAY_VALUES.indexOf(rrule.byday[d]) < 0) {
                                throw "Recurrence rrule 'byday' values must include only the following: 'SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA'"
                            }
                        }
                    }
                }
            }

            // TODO add time and time zone? use moment to format?
            const start_date = new Date(begin)
            const end_date = new Date(stop)
            const now_date = new Date()

            const start_year = (`0000${start_date.getFullYear().toString()}`).slice(-4)
            const start_month = (`00${(start_date.getMonth() + 1).toString()}`).slice(-2)
            const start_day = (`00${start_date.getDate().toString()}`).slice(-2)
            const start_hours = (`00${start_date.getHours().toString()}`).slice(-2)
            const start_minutes = (`00${start_date.getMinutes().toString()}`).slice(-2)
            const start_seconds = (`00${start_date.getSeconds().toString()}`).slice(-2)

            const end_year = (`0000${end_date.getFullYear().toString()}`).slice(-4)
            const end_month = (`00${(end_date.getMonth() + 1).toString()}`).slice(-2)
            // var end_day = ("00" + ((end_date.getDate()).toString())).slice(-2);
            const end_day = (`00${(end_date.getDate() + 1).toString()}`).slice(-2)
            const end_hours = (`00${end_date.getHours().toString()}`).slice(-2)
            const end_minutes = (`00${end_date.getMinutes().toString()}`).slice(-2)
            const end_seconds = (`00${end_date.getSeconds().toString()}`).slice(-2)

            const now_year = (`0000${now_date.getFullYear().toString()}`).slice(-4)
            const now_month = (`00${(now_date.getMonth() + 1).toString()}`).slice(-2)
            const now_day = (`00${now_date.getDate().toString()}`).slice(-2)
            const now_hours = (`00${now_date.getHours().toString()}`).slice(-2)
            const now_minutes = (`00${now_date.getMinutes().toString()}`).slice(-2)
            const now_seconds = (`00${now_date.getSeconds().toString()}`).slice(-2)

            // Since some calendars don't add 0 second events, we need to remove time if there is none...
            let start_time = ''
            let end_time = ''
            if (start_hours + start_minutes + start_seconds + end_hours + end_minutes + end_seconds !== '0') {
                start_time = `T${start_hours + start_minutes + start_seconds}`
                end_time = `T${end_hours + end_minutes + end_seconds}`
            }
            const now_time = `T${now_hours + now_minutes + now_seconds}`

            const start = start_year + start_month + start_day // + start_time
            const end = end_year + end_month + end_day // + end_time
            const now = now_year + now_month + now_day + now_time

            // recurrence rrule vars
            let rruleString
            if (rrule) {
                if (rrule.rrule) {
                    rruleString = rrule.rrule
                } else {
                    rruleString = `rrule:FREQ=${rrule.freq}`

                    if (rrule.until) {
                        const uDate = new Date(Date.parse(rrule.until)).toISOString()
                        rruleString += `;UNTIL=${uDate.substring(0, uDate.length - 13).replace(/[-]/g, '')}000000Z`
                    }

                    if (rrule.interval) {
                        rruleString += `;INTERVAL=${rrule.interval}`
                    }

                    if (rrule.count) {
                        rruleString += `;COUNT=${rrule.count}`
                    }

                    if (rrule.byday && rrule.byday.length > 0) {
                        rruleString += `;BYDAY=${rrule.byday.join(',')}`
                    }
                }
            }

            const stamp = new Date().toISOString()
            let calendarEvent = []
            if (!isCancel) {
                calendarEvent = [
                    'METHOD:REQUEST',
                    // Start: cài đặt time zone Japan
                    'BEGIN:VTIMEZONE',
                    'TZID:Japan',
                    'BEGIN:STANDARD',
                    'DTSTART:19390101T000000',
                    'TZOFFSETFROM:+0900',
                    'TZOFFSETTO:+0900',
                    'TZNAME:JST',
                    'END:STANDARD',
                    'END:VTIMEZONE',
                    // End: cài đặt time zone Japan
                    'BEGIN:VEVENT',
                    `ORGANIZER:Mailto:${organizer}`,
                    // `ATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=NEEDS-ACTION;RSVP=TRUE;CN=kaigi-test1@cubesystem.co.jp:MAILTO:kaigi-test1@cubesystem.co.jp`,
                    /** subject.split('-')[subject.split('-')["length"] - 1]: Là nittei_id */
                    // 'UID:' + shainCd + subject.split('-')[subject.split('-')["length"] - 1] + now + "@" + newUidDomain,
                    `UID:${shainCd}${nitteiId}@${newUidDomain}`,
                    'CLASS:PUBLIC',
                    `DESCRIPTION:${description}`,
                    `DTSTAMP;TZID=Japan:${now}`,
                    `DTSTART;TZID=Japan:${start}`,
                    `DTEND;TZID=Japan:${end}`,
                    `LOCATION:${location}`,
                    `SUMMARY;LANGUAGE=en-us:${subject}`,
                    'TRANSP:TRANSPARENT',
                    'END:VEVENT',
                ]
            } else {
                calendarEvent = [
                    'METHOD:CANCEL',
                    // Start: cài đặt time zone Japan
                    'BEGIN:VTIMEZONE',
                    'TZID:Japan',
                    'BEGIN:STANDARD',
                    'DTSTART:19390101T000000',
                    'TZOFFSETFROM:+0900',
                    'TZOFFSETTO:+0900',
                    'TZNAME:JST',
                    'END:STANDARD',
                    'END:VTIMEZONE',
                    // End: cài đặt time zone Japan
                    'BEGIN:VEVENT',
                    `ORGANIZER:Mailto:${organizer}`,
                    // 'UID:' + subject.split('-')[subject.split('-')["length"]-1] + "@" + newUidDomain,
                    `UID:${shainCd}${nitteiId}@${newUidDomain}`,
                    'CLASS:PUBLIC',
                    `DESCRIPTION:${description}`,
                    `DTSTAMP;TZID=Japan:${now}`,
                    `DTSTART;TZID=Japan:${start}`,
                    `DTEND;TZID=Japan:${end}`,
                    `LOCATION:${location}`,
                    'STATUS:CANCELLED',
                    `SUMMARY;LANGUAGE=en-us:${subject}`,
                    'TRANSP:TRANSPARENT',
                    'END:VEVENT',
                ]
                // calendarEvent = [
                //     'METHOD:REQUEST',
                //     'BEGIN:VEVENT',
                //     'ORGANIZER:Mailto:' + organizer,
                //     'SEQUENCE:1',
                //     'X-MICROSOFT-CDO-APPT-SEQUENCE:1',
                //     'UID:' + calendarEvents.length + "@" + uidDomain,
                //     'CLASS:PUBLIC',
                //     'DESCRIPTION:' + description,
                //     'DTSTAMP;VALUE=DATE-TIME:' + now,
                //     'DTSTART;VALUE=DATE-TIME:' + start,
                //     'DTEND;VALUE=DATE-TIME:' + end,
                //     'LOCATION:' + location,
                //     'SUMMARY;LANGUAGE=en-us:' + subject,
                //     'TRANSP:TRANSPARENT',
                //     'END:VEVENT'
                //   ];
            }

            if (rruleString) {
                calendarEvent.splice(4, 0, rruleString)
            }

            const newCalendarEvent = calendarEvent.join(SEPARATOR)

            calendarEvents.push(newCalendarEvent)
            return newCalendarEvent
        },

        /**
         * Download calendar using the saveAs function from filesave.js
         * @param  {string} filename Filename
         * @param  {string} ext      Extention
         */
        download(filename: string, ext?: string) {
            let newFileName = ''
            let newext = ''
            if (calendarEvents.length < 1) {
                return false
            }

            newext = typeof ext !== 'undefined' ? ext : '.ics'
            newFileName = typeof filename !== 'undefined' ? filename : 'calendar'
            const calendar = calendarStart + SEPARATOR + calendarEvents.join(SEPARATOR) + calendarEnd

            let blob
            if (navigator.userAgent.indexOf('MSIE 10') === -1) {
                // chrome or firefox
                blob = new Blob([calendar])
            }
            //   else { // ie
            //     var bb = new BlobBuilder();
            //     bb.append(calendar);
            //     blob = bb.getBlob('text/x-vCalendar;charset=' + document.characterSet);
            //   }
            saveAs(blob, newFileName + newext)
            return calendar
        },

        /**
         * Build and return the ical contents
         */
        build() {
            if (calendarEvents.length < 1) {
                return ''
            }

            const calendar = calendarStart + SEPARATOR + calendarEvents.join(SEPARATOR) + calendarEnd

            return calendar
        },
    }
}
