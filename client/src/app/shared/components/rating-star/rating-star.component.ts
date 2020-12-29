import { Component, Input, OnChanges } from '@angular/core'

@Component({
    selector: 'app-rating-star',
    templateUrl: './rating-star.component.html',
    styleUrls: ['./rating-star.component.scss'],
})
export class RatingStarComponent implements OnChanges {
    @Input() max = 5
    @Input() rating = 5
    public ratingPercent = '100%'
    public starArr = Array(5)

    constructor() {}

    ngOnChanges(): void {
        this.ratingPercent = Math.round((this.rating * 100) / this.max) + '%'
        this.starArr = Array(this.max)
    }
}
