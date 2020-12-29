import { Component, OnInit } from '@angular/core'
import { SharedService } from '@app/shared/shared.service'
import { Router } from '@angular/router'
import { MatSnackBar, MatDialog } from '@angular/material'
import { SavedSettingsService } from './saved-settings.service'
import common from '@app/common'
@Component({
    selector: 'app-saved-settings',
    templateUrl: './saved-settings.component.html',
    styleUrls: ['./saved-settings.component.scss'],
})
export class SavedSettingsComponent implements OnInit {
    time
    constructor(private sharedService: SharedService, public snackBar: MatSnackBar, private router: Router, public dialog: MatDialog, public savedService: SavedSettingsService) {
        this.sharedService.setTitle('共通設定')
    }

    ngOnInit() {
        this.fetchData()
    }
    /*
        - Lấy dữ liệu mặc định cho this.time từ server
    */
    fetchData() {
        this.savedService.getDetailTimeSearch(1).subscribe((res) => {
            this.time = res.data.saving_search_time
        })
    }
    /*
        - Update this.time
    */
    editTimeSearch() {
        this.savedService.updateTimeSearch(this.time).subscribe((res) => {
            if (res.code === 0) {
                this.snackBar.open(common.message.SETT001)
                setTimeout(() => this.snackBar.dismiss(), 3000)
            } else {
                this.snackBar.open(common.message.SETT002)
                setTimeout(() => this.snackBar.dismiss(), 3000)
            }
        })
    }
}
