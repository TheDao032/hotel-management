import { Injectable } from '@angular/core'
import {
    CanActivate,
    ActivatedRouteSnapshot,
    RouterStateSnapshot,
    Router,
} from '@angular/router'

import { Observable } from 'rxjs'
import { map, tap } from 'rxjs/operators'

import { AuthService } from './auth.service'

import { detectIE } from '../common/detectIE'

@Injectable({
    providedIn: 'root',
})
export class UnauthGuard implements CanActivate {
    version = detectIE()
    constructor(private auth: AuthService, private route: Router) {}
    canActivate(
        next: ActivatedRouteSnapshot,
        state: RouterStateSnapshot
    ): Observable<boolean> | Promise<boolean> | boolean {
        if (this.version === false) {
            return this.auth.isLoggedIn().pipe(
                map((user) => !user),
                tap((result) => {
                    if (!result) this.auth.goHome()
                })
            )
        }
        this.auth.goUnSupportedBrowser()
    }
}
