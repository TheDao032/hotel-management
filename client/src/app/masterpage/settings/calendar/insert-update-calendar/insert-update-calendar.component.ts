import { Component, OnInit, Inject, ElementRef, ViewChild } from '@angular/core'
import { MAT_DIALOG_DATA, MatAutocompleteSelectedEvent, MatAutocomplete, fadeInItems, MatDialogRef, MatDialog } from '@angular/material'
import { COMMA, ENTER } from '@angular/cdk/keycodes'
import { MatChipInputEvent } from '@angular/material/chips'
import { startWith, map } from 'rxjs/operators'
import { Observable } from 'rxjs'
import { FormControl, FormBuilder, FormGroup } from '@angular/forms'
import { CalendarService } from '../calendar.service'
import * as moment from 'moment'

export interface Location {
    displayName: string
}

export interface Attendee {
    type: string
    emailAddress: {
        name: string
        address: string
    }
}

@Component({
    selector: 'app-insert-update-calendar',
    templateUrl: './insert-update-calendar.component.html',
    styleUrls: ['./insert-update-calendar.component.scss'],
})
export class InsertUpdateCalendarComponent implements OnInit {
    scheduleList = []
    scheduleForm: FormGroup = this.formBuilder.group({
        event_id: [
            {
                value: '',
            },
        ],
        event_title: [
            {
                value: '',
                disabled: false,
            },
        ],
        start_date: [
            {
                value: '',
            },
        ],
        end_date: [
            {
                value: '',
            },
        ],
        event_note: [
            {
                value: '',
            },
        ],
    })
    eventId: any = ''
    calendar_event = {
        subject: '',
        // attendees: '',
        start_date: new Date(),
        end_date: new Date(),
        // location: '',
        content: '',
    }

    visible = true
    selectable = true
    removable = true
    addOnBlur = true
    separatorKeysCodes: number[] = [ENTER, COMMA]
    //location
    locationCtrl = new FormControl()
    filteredLocations: Observable<string[]>
    locations: string[] = []
    allLocations: string[] = ['Vietnam', 'Japan']
    //attendee
    attendeeCtrl = new FormControl()
    filteredAttendees: Observable<string[]>
    attendees: string[] = []
    allAttendees: string[] = ['Khang', 'Thien']

    startTimeCtrl = new FormControl()
    filteredOptionsStart: Observable<string[]>
    endTimeCtrl = new FormControl()
    filteredOptionsEnd: Observable<string[]>
    AllOptions: string[] = ['00:00', '11:00', '22:00']

    @ViewChild('locationInput', { static: false }) locationInput: ElementRef<HTMLInputElement>
    @ViewChild('attendeeInput', { static: false }) attendeeInput: ElementRef<HTMLInputElement>
    @ViewChild('startTimeInput', { static: false }) startTimeInput: ElementRef<HTMLInputElement>
    @ViewChild('endTimeInput', { static: false }) endTimeInput: ElementRef<HTMLInputElement>

    @ViewChild('auto', { static: false }) matAutocompleteLocation: MatAutocomplete
    @ViewChild('auto2', { static: false }) matAutocompleteAttendee: MatAutocomplete
    @ViewChild('auto3', { static: false }) matAutocompleteStartTime: MatAutocomplete
    @ViewChild('auto4', { static: false }) matAutocompleteEndTime: MatAutocomplete

    constructor(@Inject(MAT_DIALOG_DATA) public parentData: any, private calendarService: CalendarService, public selfDialog: MatDialogRef<InsertUpdateCalendarComponent>, public dialog: MatDialog, private formBuilder: FormBuilder) {
        this.parentData = {
            ...this.parentData,
        }

        this.filteredLocations = this.locationCtrl.valueChanges.pipe(
            startWith(null),
            map((location: string | null) => (location ? this._filter(location, 'location') : this.allLocations.slice()))
        )

        this.filteredAttendees = this.attendeeCtrl.valueChanges.pipe(
            startWith(null),
            map((attendee: string | null) => (attendee ? this._filter(attendee, 'attendee') : this.allAttendees.slice()))
        )

        this.filteredOptionsStart = this.startTimeCtrl.valueChanges.pipe(
            startWith(null),
            map((value) => (value ? this._filter(value, 'startTime') : this.AllOptions.slice()))
        )

        this.filteredOptionsEnd = this.endTimeCtrl.valueChanges.pipe(
            startWith(null),
            map((value) => (value ? this._filter(value, 'endTime') : this.AllOptions.slice()))
        )
    }

    ngOnInit() {
        //
        if (this.parentData.event) {
            //
            let locationArr = []
            let attendeeArr: Attendee[] = []
            if (!this.parentData.event.isloading) {
                this.getDataEvent()
            } else {
                this.getDateEventToCalender()
            }

            locationArr = this.parentData.event.location.displayName.split(';')
            attendeeArr = this.parentData.event.attendees
            attendeeArr.forEach((element) => {
                this.attendees.push(element.emailAddress.address)
            })
            locationArr.forEach((element2) => {
                //
                this.locations.push(element2)
            })

            this.eventId = this.parentData.event.id
            // this.attendeeCtrl.patchValue(this.attendees)
            // this.locationCtrl.patchValue(this.locations)
        }
    }
    getDataEvent() {
        this.calendar_event.subject = this.parentData.event.subject
        this.calendar_event.content = this.parentData.event.bodyPreview
        this.calendar_event.start_date = this.parentData.event.start.dateTime.split('T')[0]
        this.calendar_event.end_date = this.parentData.event.end.dateTime.split('T')[0]
        this.startTimeCtrl.patchValue(this.parentData.event.start.dateTime.split('T')[1].substring(0, 5))
        this.endTimeCtrl.patchValue(this.parentData.event.end.dateTime.split('T')[1].substring(0, 5))
        //console.log(this.parentData.event.end.dateTime.split('T')[1].substring(0, 5))
    }
    getDateEventToCalender() {
        this.calendar_event.subject = this.parentData.event.subject
        this.calendar_event.content = this.parentData.event.bodyPreview
        this.calendar_event.start_date = this.parentData.event.start.substring(0, 10)
        this.calendar_event.end_date = this.parentData.event.end.substring(0, 10)
        this.startTimeCtrl.patchValue(this.parentData.event.start.substring(11, 16))
        this.endTimeCtrl.patchValue(this.parentData.event.end.substring(11, 16))
    }

    addLocation(event: MatChipInputEvent): void {
        // Add location only when MatAutocomplete is not open
        // To make sure this does not conflict with OptionSelected Event
        if (!this.matAutocompleteLocation.isOpen) {
            const input = event.input
            const value = event.value

            // Add our fruit
            if ((value || '').trim()) {
                this.locations.push(value.trim())
            }

            // Reset the input value
            if (input) {
                input.value = ''
            }

            this.locationCtrl.setValue(null)
        }
    }

    removeLocation(location: string): void {
        const index = this.locations.indexOf(location)

        if (index >= 0) {
            this.locations.splice(index, 1)
        }
    }

    selected(event: MatAutocompleteSelectedEvent, type: string): void {
        if (type === 'location') {
            this.locations.push(event.option.viewValue)
            this.locationInput.nativeElement.value = ''
            this.locationCtrl.setValue(null)
        } else if (type === 'attendee') {
            this.attendees.push(event.option.viewValue)
            // this.attendees.push({emailAddress: {address: event.option.viewValue, name: ''}, type: 'required'}); //event.option.viewValue
            this.attendeeInput.nativeElement.value = ''
            this.attendeeCtrl.setValue(null)
        }
    }

    // Attendees
    addAttendee(event: MatChipInputEvent): void {
        // Add fruit only when MatAutocomplete is not open
        // To make sure this does not conflict with OptionSelected Event
        if (!this.matAutocompleteAttendee.isOpen) {
            const input = event.input
            const value = event.value

            // Add our fruit
            if ((value || '').trim()) {
                this.attendees.push(value.trim())
            }

            // Reset the input value
            if (input) {
                input.value = ''
            }

            this.attendeeCtrl.setValue(null)
        }
    }

    removeAttendee(attendee: string): void {
        const index = this.attendees.indexOf(attendee)

        if (index >= 0) {
            this.attendees.splice(index, 1)
        }
    }

    private _filter(value: string, type: string): string[] {
        const filterValue = value.toLowerCase()

        switch (type) {
            case 'location': {
                return this.allLocations.filter((location) => location.toLowerCase().indexOf(filterValue) === 0)
            }
            case 'attendee': {
                return this.allAttendees.filter((attendee) => attendee.toLowerCase().indexOf(filterValue) === 0)
            }
            case 'startTime': {
                return this.AllOptions.filter((option) => option.toLowerCase().includes(filterValue))
            }
            case 'endTime': {
                return this.AllOptions.filter((option) => option.toLowerCase().includes(filterValue))
            }
        }
    }

    save() {
        const start_year = new Date(this.calendar_event.start_date).getFullYear()
        const start_month = new Date(this.calendar_event.start_date).getMonth() + 1
        const start_day = new Date(this.calendar_event.start_date).getDate()
        const start_dateTime = `${start_year}-${start_month}-${start_day}T${this.startTimeCtrl.value}:00`
        const end_year = new Date(this.calendar_event.end_date).getFullYear()
        const end_month = new Date(this.calendar_event.end_date).getMonth() + 1
        const end_day = new Date(this.calendar_event.end_date).getDate()
        const end_dateTime = `${end_year}-${end_month}-${end_day}T${this.endTimeCtrl.value}:00`

        const attendeeArr: Attendee[] = []
        const locationArr: Location[] = []

        this.locations.forEach((element) => {
            locationArr.push({ displayName: element })
        })
        this.attendees.forEach((element) => {
            attendeeArr.push({ emailAddress: { address: element, name: element.split('@')[0] }, type: 'required' })
        })
        const event = {
            subject: this.calendar_event.subject,
            body: {
                contentType: 'HTML',
                content: this.calendar_event.content,
            },
            start: {
                dateTime: start_dateTime,
                timeZone: 'Pacific Standard Time',
            },
            end: {
                dateTime: end_dateTime,
                timeZone: 'Pacific Standard Time',
            },
            locations: locationArr,
            attendees: attendeeArr,
        }

        //
        this.calendarService.createOrUpdateEvent(JSON.parse(this.parentData.token), event, this.eventId).subscribe(
            (res) => {
                if (res.code === 0) {
                    this.selfDialog.close({
                        type: res.type,
                        isSuccess: res.code,
                    })
                }
            },
            (err) => {
                this.selfDialog.close({
                    type: err.type,
                    isSuccess: err.code,
                    error: err.error,
                })
            }
        )
        const params = {
            event_id: this.parentData.event.event_id || 0,
            event_note: this.calendar_event.content,
            event_title: this.calendar_event.subject,
            start_ts: start_dateTime,
            end_ts: end_dateTime,
        }
        this.calendarService.updateSchedule(params).subscribe(
            (res) => {
                this.selfDialog.close()
                if (res.code === 0) {
                }
            },
            (err) => {
                if (err.error.code === 1) {
                }
            }
        )
    }

    discardEvent() {
        const discardMessage = 'Are you sure?'
        const answer = false
        const dialogRef = this.dialog.open(ConfirmDiscardComponent, {
            data: { discardMessage, answer },
        })
        dialogRef.afterClosed().subscribe((result) => {
            if (result) {
                this.calendarService.deleteEventID(this.parentData.event.event_id).subscribe(
                    (res) => {
                        if (res.code === 2) {
                            return
                        }
                        if (res.code === 0) {
                        } else {
                        }
                    },
                    (err) => {}
                )
                this.calendarService.deleteEvent(JSON.parse(this.parentData.token), this.eventId).subscribe(
                    (res) => {
                        if (res.code === 0) {
                            this.selfDialog.close({
                                type: res.type,
                                isSuccess: res.code,
                            })
                        }
                    },
                    (err) => {
                        this.selfDialog.close({
                            type: err.type,
                            isSuccess: err.code,
                            error: err.error,
                        })
                    }
                )
            }
        })
    }
}

@Component({
    selector: 'app-confirm-discard-dialog',
    templateUrl: './confirm-discard.html',
})
export class ConfirmDiscardComponent {
    constructor(@Inject(MAT_DIALOG_DATA) public data: any) {}
}
