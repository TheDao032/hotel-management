import { Component, OnInit } from '@angular/core'
import { MatSnackBar, MatDialog } from '@angular/material'

import { PermissionDialogComponent } from './permission-dialog'
import { PermissionService } from './permission.service'
import { SharedService } from '@app/shared/shared.service'
import common from '@app/common'

@Component({
    selector: 'app-permission',
    templateUrl: './permission.component.html',
    styleUrls: ['./permission.component.scss'],
    providers: [PermissionService],
})
export class PermissionComponent implements OnInit {
    permissionList = ['01', '70', '99']
    shainList = []
    permissionData = []
    searchForm = {
        shain_cd: '',
        permission_cd: '',
    }
    gridViewData
    loading = false

    constructor(
        private sharedService: SharedService,
        private permissionService: PermissionService,
        private dialog: MatDialog,
        public snackBar: MatSnackBar
    ) {}

    ngOnInit() {
        this.sharedService.setTitle('権限設定')
        this.getPermissionList()
        this.permissionService.getShainCdList().subscribe((res) => {
            // Split data to prevent blocking event loop. Add 100 shain data each loop
            const pages = Math.floor(res.data.length / 100)
            for (let i = 0; i <= pages; i++) {
                setTimeout(() => {
                    const slicedData = res.data.slice(i * 100, (i + 1) * 100)
                    this.shainList = this.shainList.concat(slicedData)
                }, 0)
            }
        })
    }

    openDialog(isCreate, permissionData = {}) {
        const dialogRef = isCreate
            ? this.dialog.open(PermissionDialogComponent, {
                  data: {
                      isCreate,
                      shainList: this.shainList,
                      permissionData: {
                          shain_cd: '',
                          shain_mei: '',
                          start_date: new Date(),
                          end_date: new Date(),
                          permission_cd: '01',
                      },
                  },
              })
            : this.dialog.open(PermissionDialogComponent, {
                  data: {
                      isCreate,
                      shainList: this.shainList,
                      permissionData,
                  },
              })

        dialogRef.afterClosed().subscribe((info) => {
            if (!info) return
            if (info.isCreate) {
                if (info.success) this.openSnackBar(common.message.PE001)
                else this.openSnackBar(common.message.PE004)
            } else {
                if (info.success) this.openSnackBar(common.message.PE002)
                else this.openSnackBar(common.message.PE005)
            }
            this.getPermissionList()
        })
    }

    getPermissionList() {
        this.loading = true
        this.permissionData = []
        this.permissionService.getPermissionList(this.searchForm).subscribe(
            (response) => {
                this.permissionData = response.data
                this.permissionData.map((item) => {
                    item.start_date = new Date(item.start_date)
                    item.end_date = new Date(item.end_date)
                    return item
                })
            },
            (err) => (this.loading = false),
            () => {
                this.loading = false
                this.filterGridview()
            }
        )
    }

    filterGridview() {
        this.gridViewData = this.permissionData.filter((i) => {
            return (
                i.permission_cd ===
                    (this.searchForm.permission_cd
                        ? this.searchForm.permission_cd
                        : i.permission_cd) &&
                i.shain_cd ===
                    (this.searchForm.shain_cd
                        ? this.searchForm.shain_cd
                        : i.shain_cd)
            )
        })
    }

    deletePermission(data) {
        this.permissionService.deletePermission(data).subscribe(
            (res) => {
                this.openSnackBar(common.message.PE003)
                this.getPermissionList()
            },
            (err) => this.openSnackBar(common.message.PE006)
        )
    }

    openSnackBar(message: string) {
        this.snackBar.open(message)
        setTimeout(() => this.snackBar.dismiss(), 3000)
    }
}
