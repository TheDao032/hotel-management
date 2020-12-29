import { Component, OnInit } from '@angular/core';
import { SharedService } from '@app/shared/shared.service';
import { Router } from '@angular/router';
import { MatSnackBar, MatDialog } from '@angular/material';
import { RecommendSettingsService } from './recommend-settings.service';

@Component({
    selector: 'app-recommend-settings',
    templateUrl: './recommend-settings.component.html',
    styleUrls: ['./recommend-settings.component.scss']
})
export class RecommendSettingsComponent implements OnInit {

    constructor(
        private sharedService: SharedService,
        public snackBar: MatSnackBar,
        private router: Router,
        public dialog: MatDialog,
        public recommendService: RecommendSettingsService,
    ) {
        this.sharedService.setTitle('レコメンド設定')
    }
    arr_recommend = []

    ngOnInit() {
        this.fetchData();
    }

    fetchData() {
        this.recommendService.getRecommends().subscribe(res => {
            this.arr_recommend = res.data
        })
    }

    saveRecommends() {
        this.recommendService.updateRecommend(this.arr_recommend).subscribe((res) => {
            if (res.code === 0) {
                this.snackBar.open('更新に成功しました。')
                setTimeout(() => this.snackBar.dismiss(), 3000)
            }
        })
        // this.arr_recommend.forEach(element => {
        //     this.recommendService.updateRecommend(element).subscribe((res) => {
        //         if (res.code === 0) {
        //             this.snackBar.open('Successfully Updated')
        //             setTimeout(() => this.snackBar.dismiss(), 3000)
        //         }
        //     })
        // });
    }
}
