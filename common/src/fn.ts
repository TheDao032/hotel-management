/**
 * Common function for both front-end and back-end
 */
class CommonFunction {
    /**
     * Check if today is within assigned number of cancellation days
     * @param startDay Deadline of event
     * @param noticeWorkDay Number of workday to notice beforehand. Default is 3
     * @param holidayList List containing holidays of the year.
     * @param includeCurrentDay Include current day when calculating notice workday.
     * @param currentDay Default is current day. Can be passed in anyday.
     */
    isExceedCancellationDay(
        startDay,
        noticeWorkDay = 3,
        holidayList = [],
        includeCurrentDay = true,
        currentDay = new Date().setHours(0, 0, 0, 0)
    ) {
        startDay = startDay.replace(/-/g, '/')
        let formattedHolidayList = holidayList
            .map((i) => new Date(i).valueOf())
            .sort()
        let now = new Date(currentDay)
        let dayLeftToStartDay =
            (new Date(startDay).valueOf() - now.valueOf()) /
            (24 * 60 * 60 * 1000)
        let workdayCount = 0
        while (workdayCount < noticeWorkDay && dayLeftToStartDay > 1) {
            dayLeftToStartDay -= 1
            now = new Date(now.valueOf() + 24 * 60 * 60 * 1000)
            if (now.getDay() !== 0 && now.getDay() !== 6)
                workdayCount +=
                    formattedHolidayList.indexOf(now.valueOf()) !== -1 ? 0 : 1
            else
                workdayCount +=
                    formattedHolidayList.indexOf(now.valueOf()) !== -1 ? -1 : 0
        }
        return (
            workdayCount + (includeCurrentDay ? 1 : 0) >= noticeWorkDay &&
            dayLeftToStartDay > 0
        )
    }

    /**
     * convert fiscal year to ki
     * @param year: number
     */
    fiscalYear2Ki(year: number, format: boolean = true) {
        const ki = Number(year) - 1971
        return (format && ('000' + ki).slice(-3)) || ki
    }

    /**
     * Convert ki to fiscal year
     * @param year: number
     */
    ki2FiscalYear(ki: number | string) {
        return Number(ki) + 1971
    }
    /**
     * Get fiscal year
     * @param date: string|number|Date
     */
    getFiscalYear(date: any = Date.now()) {
        const d = new Date(date)
        const y = d.getMonth() >= 3 ? d.getFullYear() : d.getFullYear() - 1
        return y
    }

    /**
     * Get Ki from date
     * @param date: string|number, defaut now
     */
    getKi(date: any = Date.now(), format: boolean = true) {
        const fiscalYear = this.getFiscalYear(date)
        return this.fiscalYear2Ki(fiscalYear, format)
    }

    /**
     * Get byte count of string
     * @param str: string
     */
    lengthInUtf8Bytes(str) {
        // Matches only the 10.. bytes that are non-initial characters in a multi-byte sequence.
        var m = encodeURIComponent(str).match(/%[89ABab]/g)
        return Math.round(str.length + (m ? m.length : 0) / 2)
    }
}

export const fn = new CommonFunction()
