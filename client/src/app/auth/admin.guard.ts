import { Injectable } from '@angular/core'
import { CanActivate, Router, CanLoad } from '@angular/router'

import { map, tap } from 'rxjs/operators'

import { AuthService } from './auth.service'

@Injectable({
    providedIn: 'root',
})
export class AdminGuard implements CanActivate, CanLoad {
    constructor(private router: Router, private authService: AuthService) {}

    canActivate() {
        return this.authService.isLoggedIn().pipe(
            map((user) => !!user && user.permission_cd === '99'),
            tap((result) => {
                if (!result) this.authService.goHome()
            })
        )
    }

    canLoad() {
        return this.authService.isLoggedIn().pipe(
            map((user) => !!user && user.permission_cd === '99'),
            tap((result) => {
                if (!result) this.authService.goHome()
            })
        )
    }
}
