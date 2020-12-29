import { Component, OnInit, ViewChild, ElementRef, ɵSWITCH_COMPILE_DIRECTIVE__POST_R3__ } from '@angular/core'
import { CalendarService } from './calendar.service'
import { EVENT_TYPE_LIST } from '@app/common/constant'
import { ActivatedRoute, Router } from '@angular/router'
import { MatDialog, MatDialogRef, MatSnackBar } from '@angular/material'
import { InsertUpdateCalendarComponent } from './insert-update-calendar/insert-update-calendar.component'
import { FullCalendarComponent } from '@fullcalendar/angular'
import { OptionsInput, EventInput, Calendar, View } from '@fullcalendar/core'
import daygrid from '@fullcalendar/daygrid'
import interaction from '@fullcalendar/interaction'
import timegrid from '@fullcalendar/timegrid'
import { FormBuilder } from '@angular/forms'
import { viewClassName } from '@angular/compiler'
const moment = require('moment')
@Component({
    selector: 'app-calendar',
    templateUrl: './calendar.component.html',
    styleUrls: ['./calendar.component.scss'],
})
export class CalendarComponent implements OnInit {
    @ViewChild('fullcalendar', { static: true, read: ElementRef }) // fullcalendar: FullCalendarComponent
    calendarRef: ElementRef
    authorization_data: any
    // calendarRef: ElementRef
    signInUrl: any
    userName: any
    calendarControl: Calendar = null
    accessToken: any
    calendar_list = []
    code: any
    selectedEvent: any = ''
    options
    arrData = []
    eventsModel: any
    refetchEventInerval
    filterForm = this.fb.group({
        eventType: [EVENT_TYPE_LIST.filter((e) => e.isShowed).map((item) => item.value)],
        cateType: [''],
        check_temporary: false,
    })

    imgUrl = `../../../../assets/images/unused/starry-night.jpg`
    constructor(
        private calendarService: CalendarService,
        private route: ActivatedRoute,
        private router: Router,
        public dialog: MatDialog,
        public selfDialog: MatDialogRef<InsertUpdateCalendarComponent>,
        public snackBar: MatSnackBar,
        private fb: FormBuilder
    ) {}

    ngOnInit() {
        this.accessToken = sessionStorage.getItem('graph_access_token')
        this.userName = sessionStorage.getItem('graph_user_name')

        if (sessionStorage.getItem('entire_data')) {
            this.authorization_data = JSON.parse(sessionStorage.getItem('entire_data'))
            this.getEvents(this.authorization_data)
        }

        /* Nếu đăng nhập outlook thành công sẽ chuyển về lại trang calendar */
        this.route.queryParams.subscribe((params) => {
            this.code = params['code'] || ''
            if (this.code !== '') {
                this.calendarService.authorizeUser(this.code).subscribe(
                    (res) => {
                        if (res.code === 0) {
                            this.authorization_data = res
                            this.getCodeOrUrl(res)
                            this.router.navigate(['settings/calendar'])
                        }
                    },
                    (err) => {
                        console.error(err)
                    }
                )
            }
        })

        this.getCodeOrUrl()

        this.calendarInit()
    }

    ngOnDestroy() {
        this.calendarControl.destroy()
    }

    /*
    * Hiển thị nút Đăng nhập Outlook nếu chưa có access Token trong session
    */
    getCodeOrUrl(data: any = '') {
        this.calendarService.getCode(data).subscribe((res) => {
            if (res.data.signInUrl) {
                this.signInUrl = res.data.signInUrl
            } else if (res.data.accessToken) {
                // this.router.navigate(['/settings/calendar'])
                sessionStorage.setItem('graph_user_name', res.data.userName.name)
                sessionStorage.setItem('graph_access_token', res.data.accessToken)
                sessionStorage.setItem('entire_data', JSON.stringify(data))
                this.accessToken = sessionStorage.getItem('graph_access_token')
                this.userName = sessionStorage.getItem('graph_user_name')
                this.getEvents(data)
            }
        })
    }

    getEvents(input) {
        this.calendarService.getEventsCalendar(input).subscribe((res) => {
            this.calendar_list = res.data.result
            // this.mergeEvent()
        })
    }

    // mergeEvent() {
    //     this.calendar_list.forEach(element => {
    //         this.calendarService.mergeEvent(element).subscribe((res) => {
    //             if(res.code === 0) {
    //                 this.calendarControl.refetchEvents();
    //             }
    //         })
    //     });
    //     return 0
    // }

    signOut() {
        sessionStorage.setItem('graph_user_name', '')
        sessionStorage.setItem('graph_access_token', '')
        sessionStorage.setItem('entire_data', '')
        location.reload()
    }

    openSnackBar(message: string) {
        this.snackBar.open(message)
        setTimeout(() => this.snackBar.dismiss(), 3000)
    }

    openDialog(isCreate = true) {
        let dialogRef
        if (isCreate) {
            dialogRef = this.dialog.open(InsertUpdateCalendarComponent, {
                data: {
                    isCreate,
                    token: sessionStorage.getItem('entire_data'),
                },
            })
        }
        else {
            dialogRef = this.dialog.open(InsertUpdateCalendarComponent, {
                data: {
                    isCreate,
                    token: sessionStorage.getItem('entire_data'),
                    event: this.selectedEvent,
                },
            })
        }

        dialogRef.afterClosed().subscribe((output) => {
            if (output === undefined) return
            if (output.isSuccess === 0) {
                if (output.type === 'insert') this.openSnackBar('Successfully Insert')
                else if (output.type === 'update') this.openSnackBar('Successfully Update')
                else if (output.type === 'delete') this.openSnackBar('Successfully Delete')
            } else {
                if (output.type === 'insert') this.openSnackBar('Failed to Insert')
                else if (output.type === 'update') this.openSnackBar('Failed to Update')
                else if (output.type === 'delete') this.openSnackBar('Failed to Delete')
            }
            this.authorization_data = JSON.parse(sessionStorage.getItem('entire_data'))
            this.getEvents(this.authorization_data)
        })
    }

    roundTheMinutes(minute) {
        if (minute <= 15) {
            return 15
        }
        if (minute <= 30) {
            return 30
        }
        if (minute <= 45) {
            return 45
        }
        return 60
    }

    calendarInit() {
        this.calendarControl = new Calendar(this.calendarRef.nativeElement, {
            header: {
                left: 'prev,next today',
                center: 'title',
                right: 'dayGridMonth,timeGridWeek,timeGridDay',
            },
            plugins: [daygrid, timegrid, interaction],
            defaultView: 'dayGridMonth',
            scrollTime: `${moment().format('HH:mm:ss')}`,
            weekNumbers: true,
            editable: true,
            eventLimit: true,
            eventOverlap: false,
            events: this.getEventList.bind(this),
            // events: [{ start: '2019-08-30 07:07:00+07', end: '2019-08-30 08:00:00+07', title: 'day la title1', event_id: 3, event_title: 'day la title1' }],
            handleWindowResize: false,
            height: () => window.innerHeight - 96 - 69,
            lazyFetching: true,
            navLinks: true,
            selectOverlap: false,
            nowIndicator: true,
            selectable: true,
            selectMirror: true,
            slotEventOverlap: false,
            bootstrapFontAwesome: true,
            eventStartEditable: false,
            eventDurationEditable: false,
            columnHeaderText: (date) => {
                const currentLocaleData = moment.localeData()
                const headerMoment = moment(date)
                const weekdaysShort = currentLocaleData.weekdaysShort(headerMoment)
                if (this.calendarControl.view.type !== 'timeGridWeek') {
                    return `${weekdaysShort}`
                }
                return `${`${headerMoment.date()} (${weekdaysShort})`}`
            },
            selectAllow: (event) => {
                return true
            },
            select: (event) => {
                let momentStart = moment(event.startStr)
                let momentEnd = moment(event.endStr)
                if (this.calendarControl.view.type === 'dayGridMonth') {
                    const day1 = momentStart.date()
                    const day2 = moment().date()
                    if (day1 === day2) {
                        momentStart = moment().add(15, 'minute')
                        const newStartMin = this.roundTheMinutes(momentStart.minute())
                        if (newStartMin === 60) {
                            momentStart.hour(momentStart.hour() + 1)
                            momentStart.minute(0)
                        } else {
                            momentStart.minute(newStartMin)
                        }
                        momentStart.second(0)

                        momentEnd =
                            moment(momentEnd).subtract(45, 'minute') <= momentStart
                                ? moment(momentStart).add(30, 'minute')
                                : moment(momentEnd).subtract(15, 'minute')
                        const newEndMin = this.roundTheMinutes(momentEnd.minute())
                        if (newEndMin === 60) {
                            momentEnd.hour(momentEnd.hour() + 1)
                            momentEnd.minute(0)
                        } else {
                            momentEnd.minute(newEndMin)
                        }
                        momentEnd.second(0)
                    } else {
                        momentStart.add(15, 'minute')
                        momentEnd.subtract(15, 'minute')
                    }
                }
                const data = {
                    event: {
                        start: momentStart.format('YYYY-MM-DD HH:mm:ss'),
                        end: momentEnd.format('YYYY-MM-DD HH:mm:ss'),

                        isloading: 1,
                        location: {
                            displayName: 'Viet Nam',
                            locationType: 'vn',
                            uniqueId: 'vn',
                            uniqueIdType: 'private',
                        },
                        attendees: [{ emailAddress: { address: 'Viet Nam', name: 'vn' } }],
                    },
                    token: sessionStorage.getItem('entire_data'),
                }
                const calendarInfoDialog = this.dialog.open(InsertUpdateCalendarComponent, { data })
                calendarInfoDialog.afterClosed().subscribe(() => {
                    this.calendarControl.unselect()
                    this.calendarControl.refetchEvents()
                })
            },
            eventClick: (schedule) => {
                // console.log(schedule)
                schedule.jsEvent.preventDefault()
                const data = {
                    event: {
                        ...schedule.event.extendedProps,
                        start: schedule.event.extendedProps.start_ts,
                        end: schedule.event.extendedProps.end_ts,
                        bodyPreview: schedule.event.extendedProps.event_note,
                        subject: schedule.event.extendedProps.event_title,
                        reloadEvents: (() => {
                            this.calendarControl.refetchEvents()
                        }).bind(this),
                        isloading: 1,
                        location: {
                            displayName: 'Viet Nam',
                            locationType: 'default',
                            uniqueId: 'Vietnam',
                            uniqueIdType: 'private',
                        },
                        attendees: [{ emailAddress: { address: 'tinh', name: 'tinh' } }],
                    },
                    token: sessionStorage.getItem('entire_data'),
                }
                const calendarInfoDialog = this.dialog.open(InsertUpdateCalendarComponent, { data })
                calendarInfoDialog.afterClosed().subscribe(() => {
                    this.calendarControl.unselect()
                    this.calendarControl.refetchEvents()
                })
            },
            eventAllow: () => {
                return true
            },
            eventRender: ({ event, el }) => {
                const fcTime = el.getElementsByClassName('fc-time')[0]
                const fcTitle = el.getElementsByClassName('fc-title')[0]
                if (fcTime) {
                    fcTime.remove()
                }

                const momentStart = moment(event.start)
                const momentEnd = moment(event.end)
                const eventLengthInHour = momentEnd.diff(momentStart, 'hour')
                const equipments = event._def.extendedProps.equipments
                const event_note = event._def.extendedProps.event_note ? `・${event._def.extendedProps.event_note}` : ''
                // const owner_name = event._def.extendedProps.owner_name ? `・${event._def.extendedProps.owner_name}` : ''
                let arrNameChild = []
                arrNameChild = equipments
                    ? equipments.map((e) => {
                          return e.category_image_url
                      })
                    : []

                const equipmentsInfo = arrNameChild.length > 0 ? `・${arrNameChild.join(', ')}` : ''
                const eventInfo = `[・${event.title}] - [・${moment(event.start).format('YYYY-MM-DD HH:mm')} -> ${moment(event.end).format('YYYY-MM-DD HH:mm')}]  ${equipments ? `- [${equipmentsInfo}]` : ''} `

                el.setAttribute('title', eventInfo)
                if (fcTitle) {
                    fcTitle.className = 'fc-title fc-content-event'
                    if (this.calendarControl.view.type === 'timeGridDay' || this.calendarControl.view.type === 'timeGridWeek') {
                        const infos = []
                        if (event_note) {
                            const eventNoteElement = document.createElement('div')
                            eventNoteElement.append(event_note)
                            infos.push(eventNoteElement)
                        }

                        const numberOfInfomation = eventLengthInHour * 6
                        for (let i = 1; i < numberOfInfomation; i += 1) {
                            if (infos.length > 0) {
                                fcTitle.appendChild(infos.shift())
                            }
                        }

                        return
                    }
                }

                if (this.calendarControl.view.type !== 'timeGridDay') {
                    if (this.calendarControl.view.type === 'dayGridMonth' && fcTitle) {
                    }
                }
                if (this.calendarControl.view.type === 'dayGridMonth') {
                    el.style.height = '2em'
                }
            },
        })
        this.calendarControl.render()
        this.refetchEventInerval = setInterval(() => {
            this.calendarControl.refetchEvents()
        }, 6 * 60 * 1000)
    }
    getEventList(options, callback) {
        const data = []
        this.calendarService.getEventList(data).subscribe(async (res) => {
            const events = await this.editEvent(res.data)
            callback([...events])
        })
    }

    async editEvent(events: any[]) {
        const newEvents = events.map((e) => ({
            ...e,
            start: e.start_ts,
            title: e.event_title,
            end: e.end_ts,
        }))
        return newEvents
    }

}
