import { Component, OnInit, ViewChild, ElementRef } from '@angular/core'
import { Router, NavigationEnd } from '@angular/router'
import { MatSidenav } from '@angular/material/sidenav'
import * as Hammer from 'hammerjs'

import { AuthService } from '@app/auth/auth.service'
import { environment } from '../../environments/environment'
import { HttpClient } from '@angular/common/http'
import { SharedService } from './../shared/shared.service'

export interface Submenu {
    id: number
    name: string
    level: string
    parent_id: string
}



@Component({
    selector: 'app-masterpage',
    templateUrl: './masterpage.component.html',
    styleUrls: ['./masterpage.component.scss'],
})
//Update By TheDao
export class MasterpageComponent implements OnInit {
    mobileQuery: MediaQueryList
    sharedService: SharedService
    @ViewChild('sidenav', { static: true }) sidenav: MatSidenav
    title: String = 'this is title'
    username: String = 'username'
    permission_cd = '01'
    now = Date.now()
    fontSize = '12px'
    subMenuList: Submenu[]
    listLvl1: Submenu[]
    listLvl2: Submenu[]
    listLvl3: Submenu[]
    setting = {
        footer_color: 'rgb(245, 245, 245)',
        footer_font_color: 'rgb(0, 0, 0)',
        header_color: 'rgb(245, 245, 245)',
        header_info_font_color: 'rgb(3, 169, 244)',
        header_menu_icon_color: 'rgb(0, 0, 0)',
        header_title_font_color: 'rgb(0, 0, 0)',
    }
    //End Update
    constructor(private auth: AuthService, private router: Router, private http: HttpClient, elementRef: ElementRef) {
        const hammertime = new Hammer(elementRef.nativeElement, {})
        hammertime.get('pan').set({ direction: Hammer.DIRECTION_ALL, threshold: 250 })
        hammertime.on('panright', (ev) => window.innerWidth < 960 && this.sidenav.open())
        this.auth.user.subscribe(({ fullname, permission_cd }) => {
            this.username = fullname
            this.permission_cd = permission_cd
        })
        this.router.events.subscribe((e) => {
            if (e instanceof NavigationEnd) this.sidenav.close()
        })
        setInterval(() => {
            this.now = Date.now()
        }, 1000)
        this.getSetting().subscribe((res: any) => {
            if (res.data) {
                this.setting = res.data
            }
        })
        this.getTemaCategory()


        // this.subMenuList = Submenu
    }

    ngOnInit() {


    }

    logout() {
        this.auth.logout(true)
    }


    //---------------- Updated By Giang

    getTemaCategory() {
        // this.sharedService.get_list_tema_category(false)
        this.sharedService.get_list_tema_category().subscribe({
            next: (next) => {
                this.subMenuList = next.data
                this.listLvl1 = this.filterItemsOfLevel('1')
                this.listLvl2 = this.filterItemsOfLevel('2')
                this.listLvl3 = this.filterItemsOfLevel('3')
            },
            error(err) {
                console.log(err)
            },
        })
    }

    filterChildOfParent(parentId:string) {
        return this.subMenuList.filter((x) => {
            return x.level === '2' && x.parent_id === parentId
        })
    }

    filterItemsOfLevel(level) {
        return this.subMenuList.filter((x) => {
            // console.log(x.level)
            return x.level === level
        })
    }

    //---------------- END UPDATE
    getSetting() {
        return this.http.post(`${environment.apiUrl}/settings/get-color-setting`, {})
    }
    //Add New Function By TheDao
    filterChildOfParentLv3(parentId:string) {
        return this.subMenuList.filter((x) => {
            return x.level === '3' && x.parent_id === parentId
        })
    }
    reLoad(id) {
        let currentRoute = "/training/list/" + id

        this.router.navigateByUrl(`/`, { skipLocationChange: true }).then(() => {
            this.router.navigate([currentRoute]); // navigate to same route
        }); 
    }
}
