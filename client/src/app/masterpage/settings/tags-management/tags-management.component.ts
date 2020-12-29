import { Component, OnInit, ElementRef, ViewChild, AfterViewInit } from '@angular/core';
import { SharedService } from '@app/shared/shared.service';
import { AuthService } from '@app/auth/auth.service';
import { FormControl } from '@angular/forms';
import { InsertUpdateTagComponent } from './insert-update-tag/insert-update-tag.component';
import { MatDialog, MatSnackBar } from '@angular/material';
import { ConfirmDeleteTagDialogComponent } from './confirm-delete-tag-dialog';
import * as common from '@app/common'

@Component({
    selector: 'app-tags-management',
    templateUrl: './tags-management.component.html',
    styleUrls: ['./tags-management.component.scss']
})
export class TagsManagementComponent implements OnInit, AfterViewInit {

    @ViewChild('search', { static: false }) searchTextBox: ElementRef
    @ViewChild('fileimport', { static: false }) fileimport: ElementRef
    permission_cd = '01'
    selectTagFormControl = new FormControl()
    searchTextboxControl = new FormControl()
    selectedValues = ''
    newData = {
        tag_id: 0,
        tag_name: '',
        tag_father_id: null,
    }
    filteredOptions = []
    tagsList = []
    arrNewTag = []

    childTag

    data: any = []
    allTags: any = []
    @ViewChild('sf', { read: ElementRef, static: true }) sf: ElementRef
    scrollH = '550px'

    myFile: File
    message: any = {}
    kensyuuIdToDelete: string
    filename = ''
    loading = false
    q_mess = ''

    constructor(
        private sharedSevice: SharedService,
        private auth: AuthService,
        private dialog: MatDialog,
        public snackBar: MatSnackBar,
    ) {
        this.sharedSevice.setTitle('タグ管理')
        this.auth.user.subscribe(({ permission_cd }) => (this.permission_cd = permission_cd))
        this.searchTextboxControl.valueChanges.subscribe((res) => {
            const newFilterdOptions: any = this._filter(res)
            this.filteredOptions = newFilterdOptions
        })
    }

    ngOnInit() {
        ;[document.getElementById('fakeBrowseFileImport'), document.getElementById('fakeFileImport')].forEach((i) =>
            i.addEventListener('click', function() {
                document.getElementById('file').click()
            })
        )
    }

    ngAfterViewInit() {
        setTimeout(() => {
            this.setHeight()
        }, 1000)
    }

    setHeight() {
        const wh = document.getElementsByClassName('app-content')[0].clientHeight
        const sfh = this.sf.nativeElement.clientHeight
        const tbHeight = wh - 48 - sfh - 80
        this.scrollH = tbHeight + 'px'
    }

    /**
       * Used to filter data based on search input
       */
    // _filter(name: string): Observable<any[]> {
    _filter(name: string) {
        const filterValue = name.toLowerCase();
        /* Set selected values to retain the selected checkbox state */
        this.setSelectedValues()

        let filteredList: any
        this.selectTagFormControl.patchValue(this.selectedValues)
        filteredList = this.tagsList.filter((option) => {
            let newObj: any = {
                tag_id: 0,
                tag_name: '',
            }
            newObj = option
            return newObj.tag_name.toString().toLowerCase().indexOf(filterValue) === 0
        });
        if (filteredList.length < 1) {
            this.newData = {
                tag_id: 0,
                tag_name: '',
                tag_father_id: null,
            }
            this.newData.tag_name = name
            this.newData.tag_id = this.allTags.length + 1
        }

        return filteredList
    }

    /**
     * Remove from selected values based on uncheck
     */
    selectionChange(event) {
        if (event.isUserInput && event.source.selected == false) {
            this.selectTagFormControl.patchValue(event.source.value)
            // let index = this.selectedValues.indexOf(event.source.value)
            // this.selectedValues.splice(index, 1)
        }
    }

    openedChange(e) {
        /* Set search textbox value as empty while opening selectbox */
        this.searchTextboxControl.patchValue('')
        /* Focus to search textbox while clicking on selectbox */
        if (e == true) {
            this.searchTextBox.nativeElement.focus()
        }
        this.filteredOptions = this.tagsList
    }

    /**
     * Clearing search textbox value
     */
    clearSearch(event) {
        event.stopPropagation()
        this.searchTextboxControl.patchValue('')
    }

    /**
     * Set selected values to retain the state
     */
    setSelectedValues() {
        // ;
        if (this.selectTagFormControl.value) {
            this.selectedValues = this.selectTagFormControl.value
            // this.selectTagFormControl.value.forEach((e) => {
            //     if (this.selectedValues.indexOf(e) == -1) {
            //         this.selectedValues.push(e)
            //     }
            // })
        }
    }

    /**
     *  Create a new tag option if it doesn't exists
     */
    createNewOption() {
        let newState
        newState = this.newData
        this.tagsList.push(newState)
        this.searchTextboxControl.patchValue('')
        // this.selectedValues.push(newState.tag_name)
        this.selectedValues = newState.tag_name
        this.selectTagFormControl.patchValue(this.selectedValues)
        this.arrNewTag.push(newState)
    }

    openDialogTag(inputData = null, type = 'create') {
        const input = this.tagsList.find((e) => inputData === e.id_tag.toString()) || {}
        const dialogRef = this.dialog.open(InsertUpdateTagComponent, {
            width: '500px',
            height: '600px',
            data: { input, type }
        })

        dialogRef.afterClosed().subscribe((info) => {
            if(info === undefined) return
            if(info.type === 'create') {
                if(info.success) {
                    this.snackBar.open('追加に成功しました。')
                } else {
                    this.snackBar.open('追加に失敗しました。')
                }
            } else if (info.type === 'update') {
                if(info.success) {
                    this.snackBar.open('更新に成功しました。')
                } else {
                    this.snackBar.open('更新に失敗しました。')
                }
            }

            setTimeout(() => this.snackBar.dismiss(), 3000)
        })
    }

    deleteTag(id, name) {
        const dialogRef = this.dialog.open(ConfirmDeleteTagDialogComponent, {
            data: { id, name, }
        })
        dialogRef.afterClosed().subscribe((info) => {
            if(info === undefined) return
            if(info.success === true) {
                this.snackBar.open('削除に成功しました。')
            } else if (info.success === false){
                this.snackBar.open('削除に失敗しました。')
            }
            setTimeout(() => this.snackBar.dismiss(), 3000)
        })
    }

    fileChange(files: any) {
        if (files.length <= 0) {
            return
        }
        this.myFile = files[0]
        this.message.myfile = ''
        this.filename = files[0].name
    }

}
