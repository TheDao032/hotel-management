import { Component, OnInit, ViewChild, ElementRef, Inject } from '@angular/core';
import { FormControl } from '@angular/forms';
import { TagsService } from '@app/masterpage/training/training-info/tags/tags.service';
import { AuthService } from '@app/auth/auth.service';
import { SharedService } from '@app/shared/shared.service';
import { MatDialogRef, MAT_DIALOG_DATA, MatDialog, MatSnackBar } from '@angular/material';
import { ConfirmDeleteTagDialogComponent } from '../confirm-delete-tag-dialog';

@Component({
    selector: 'app-insert-update-tag',
    templateUrl: './insert-update-tag.component.html',
    styleUrls: ['./insert-update-tag.component.scss']
})
export class InsertUpdateTagComponent implements OnInit {

    @ViewChild('search', { static: false }) searchTextBox: ElementRef
    permission_cd = '01'
    shain_cd = '000000'
    selectTagFormControl = new FormControl()
    tagFormControl = new FormControl()
    searchTextboxControl = new FormControl()
    selectedValues = ''
    newData = {
        id_tag: 0,
        tag_name: '',
        id_tag_father: null,
    }
    newChildData = {
        id_tag: 0,
        tag_name: '',
        id_tag_father: null,
    }
    filteredOptions = []
    tagsList = []
    arrNewTag = []
    childTag = ''
    hasChild = true
    header = ''
    allTag = []
    id_tag = 0
    buttonName = ''
    constructor(
        private sharedSevice: SharedService,
        private auth: AuthService,
        private tagsService: TagsService,
        private dialog: MatDialog,
        public snackBar: MatSnackBar,
        public selfDialog: MatDialogRef<InsertUpdateTagComponent>,
        @Inject(MAT_DIALOG_DATA) public parentData: any = null
    ) {
        this.sharedSevice.setTitle('タグ管理')
        this.auth.user.subscribe(({ permission_cd, shain_cd }) => {
            this.permission_cd = permission_cd
            this.shain_cd = shain_cd
        })
        this.searchTextboxControl.valueChanges.subscribe((res) => {
            const newFilterdOptions: any = this._filter(res)
            this.filteredOptions = newFilterdOptions
        })
        this.header = this.parentData.type === 'update' ? '変更' : '追加'
        this.buttonName = this.parentData.type === 'update' ? '更新' : '保存'
        // this.selectTagFormControl.valueChanges.subscribe((res) => {
        //     this.selectedValues = this.selec
        // })
    }

    ngOnInit() {
        if(this.parentData.input !== {}) {
            if (this.parentData.input.id_tag_father !== null) {
                this.selectedValues = this.parentData.input.id_tag_father
                this.selectTagFormControl.patchValue(this.parentData.input.id_tag_father)
                this.childTag = this.parentData.input.tag_name
                this.id_tag = this.parentData.input.id_tag
                // this.selectChildTagFormControl.patchValue(this.parentData.input.id_tag.toString())
            } else {
                this.hasChild = false
                this.tagFormControl.patchValue(this.parentData.input.tag_name)
            }
        }
        this.getAllTag();
    }

    getAllTag() {
        this.tagsService.getAllTag().subscribe((res) => {
            this.tagsList = res.data
            this.filteredOptions = this.tagsList
            // this.allTag = res.data2
            this.allTag = res.data5
        })
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
                id_tag: 0,
                tag_name: '',
                id_tag_father: null,
            }
            newObj = option
            return newObj.tag_name.toString().toLowerCase().indexOf(filterValue) === 0
        });
        if (filteredList.length < 1) {
            this.newData = {
                id_tag: 0,
                tag_name: '',
                id_tag_father: null,
            }
            this.newData.tag_name = name
            const maxId = this.allTag.length > 0 ? Math.max.apply(Math, this.allTag.map((o) => { return o.id_tag; })) : this.allTag.length
            this.newData.id_tag = maxId + 1
        }


        return filteredList
    }

    /**
     * Remove from selected values based on uncheck
     */
    selectionChange(event) {
        // console.log(input)
        // this.selectedValues = input
        // this.id_tag = input
        if (event.isUserInput && event.source.selected == false) {
            this.selectTagFormControl.patchValue(event.source.value)
            // console.log(this.selectTagFormControl.value)
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
        this.allTag.push(newState)
        this.searchTextboxControl.patchValue('')
        // this.selectedValues.push(newState.tag_name)
        this.selectedValues = newState.id_tag
        this.selectTagFormControl.patchValue(this.selectedValues)
        // this.arrNewTag.push(newState)
        // console.log(this.tagsList)
        // console.log(newState)
    }

    createOrUpdate()  {

        // this.tagsService.getAllTag().subscribe((res) => {
        //     this.tagsList = res.data
        //     this.allTag = res.data5

        // })
        if (this.childTag) {
            this.newChildData.tag_name = this.childTag
            const maxId = this.allTag.length > 0 ? Math.max.apply(Math, this.allTag.map((o) => { return o.id_tag; })) : this.allTag.length
            this.newChildData.id_tag = maxId + 1
            const findId = this.tagsList.find((e) => {
                return e.id_tag === this.selectedValues
            })
            if (findId) {
                this.newChildData.id_tag_father = findId.id_tag
            }
            // const findName = this.allTag.find((e) => {
            //     return e.tag_name.toLowerCase() === this.childTag.toLowerCase()
            // })
            // if(findName) {
            //     this.newChildData.id_tag = findName.id_tag
            //     this.newChildData.tag_name = findName.tag_name
            // }
            if (this.parentData.type === 'update') {
                this.newChildData.id_tag = this.parentData.input.id_tag
            }
        }

        if (this.tagFormControl.value) {
            this.newChildData.id_tag = this.parentData.input.id_tag
            if(this.allTag.length === 0) {
                this.newChildData.id_tag = 1
            }
            if(this.tagsList.length === 0) {
                const maxId = this.allTag.length > 0 ? Math.max.apply(Math, this.allTag.map((o) => { return o.id_tag; })) : this.allTag.length
                this.newChildData.id_tag = maxId + 1
            }
            this.newChildData.tag_name = this.tagFormControl.value
        }

        this.tagsService.insertOrUpdateTag(this.newData, this.newChildData, this.parentData.type, this.shain_cd).subscribe((res) => {
                this.selfDialog.close({
                    type: this.parentData.type,
                    success: true,
            }),
            (err) =>
                this.selfDialog.close({
                    type: this.parentData.type,
                    success: false,
                })
        })
    }

    deleteTag(id, name) {
        // console.log(input)
        const dialogRef = this.dialog.open(ConfirmDeleteTagDialogComponent, {
            data: { id, name }
        })
        dialogRef.afterClosed().subscribe((info) => {
            if(info === undefined) return
            if(info.success === true) {
                this.snackBar.open('削除に成功しました。')
                this.selfDialog.close({
                    type: 'delete',
                    success: true,
                })
            } else if (info.success === false) {
                this.selfDialog.close({
                    type: 'delete',
                    success: true,
                })
                this.snackBar.open('削除に失敗しました。')
            }
            setTimeout(() => this.snackBar.dismiss(), 3000)
            this.getAllTag()
        })
    }

}
