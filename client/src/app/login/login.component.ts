import { Component, OnInit } from '@angular/core'
import { Router } from '@angular/router'
import { AuthService } from '@app/auth/auth.service'
import * as common from '@app/common'
@Component({
    selector: 'app-login',
    templateUrl: './login.component.html',
    styleUrls: ['./login.component.css'],
})
export class LoginComponent implements OnInit {
    // user_id: String
    // user_password: String
    message
    user: any = {
        user_id: '',
        password: '',
    }
    constructor(private router: Router, private authenticationService: AuthService) {}

    ngOnInit() {
        document.getElementById('password').addEventListener(
            'keyup',
            function(event) {
                event.preventDefault()
                if (event.keyCode === 13) this.login()
            }.bind(this)
        )
    }

    login() {
        if (this.user.user_id === '') {
            this.message = common.message.W010({ param: 'ユーザーID' })
            // this.message = 'ユーザーID 項目を入力してください。'
            return
        }
        if (this.user.password === '') {
            this.message = common.message.W010({ param: 'パスワード' })
            // this.message = 'パスワード 項目を入力してください。'
            return
        }
        this.authenticationService.login(this.user.user_id, this.user.password).subscribe(
            (result) => {
                if (result) {
                    this.message = ''
                    this.router.navigate(['/home'])
                }
            },
            (err) => {
                this.user.password = ''
                this.message = err == 3 || (err == false && common.message.AU001) || (err == 6 && common.message.AU001) || common.message.AU002
            }
        )
    }
}
