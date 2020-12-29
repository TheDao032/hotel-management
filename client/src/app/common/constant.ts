import * as moment from 'moment'
export const EVENT_TYPE_LIST = [
    {
        id: 'calendar_my_event',
        text: 'My Event',
        value: 'self',
        isShowed: true,
    },
    {
        id: 'calendar_relative_event',
        text: 'Event relevant to me',
        value: 'relevant',
        isShowed: true,
    },
    {
        id: 'calendar_others_event',
        text: 'Event from others',
        value: 'others',
        isShowed: true,
    },
    {
        id: 'calendar_jp_event',
        text: `Japanese's Holiday`,
        value: 'jpHoliday',
        isShowed: false,
    },
    {
        id: 'calendar_vn_event',
        text: `Vietnamese's Holiday`,
        value: 'vnHoliday',
        isShowed: false,
    },
]

export const toTimeZone = (beforeTime = moment(), timezone = '+07:00', dateFormat = 'YYYY-MM-DD', timeFormat = 'HH:mm:ss') => {
    const operator = timezone.slice(0, 1)
    const hour = Number(timezone.slice(1, 3))
    const minute = Number(timezone.slice(4))
    const afterTime = moment(beforeTime)
        .utc()
        .add(Number(operator + hour), 'hour')
        .add(Number(operator + minute), 'minute')
    return moment(`${afterTime.format(dateFormat)}T${afterTime.format(timeFormat)}${timezone}`)
}
