import { Component, OnInit } from '@angular/core'
import { Router } from '@angular/router'
import { AuthService } from '@app/auth/auth.service'
import * as common from '@app/common'
import { FormsModule } from '@angular/forms'
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
        user_name: '',
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
        if (this.user.user_name === '') {
            this.message = common.message.W010({ param: 'employee_id' })
            return
        }
        if (this.user.password === '') {
            this.message = common.message.W010({ param: 'password' })
            return
        }
        this.authenticationService.login(this.user.user_name, this.user.password).subscribe(
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
