import { Directive, ElementRef, HostListener, Input } from '@angular/core'

@Directive({
    selector: '[appDev]',
})
export class DevDirective {
    @Input('appDev') highlightColor: string

    constructor(private el: ElementRef) {
        this.highlight(this.highlightColor || 'lightblue')
    }

    // @HostListener('mouseenter') onMouseEnter() {
    //   this.highlight('yellow');
    // }

    // @HostListener('mouseleave') onMouseLeave() {
    //   this.highlight(null || 'lightblue');
    // }

    private highlight(color: string) {
        this.el.nativeElement.style.backgroundColor = color
    }
}
