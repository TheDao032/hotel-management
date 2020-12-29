import { Injectable } from '@angular/core'
import { HttpClient } from '@angular/common/http'
import { Router } from '@angular/router'

import { ReplaySubject, of } from 'rxjs'
import { map, tap } from 'rxjs/operators'

import { environment } from '@env/environment'

@Injectable({
    providedIn: 'root',
})
export class AuthService {
    // public static instance: AuthService = undefined
    public api = environment.apiUrl

    private token: string = null
    private userInstance = null
    private userSrc = new ReplaySubject<any>(null)
    readonly user = this.userSrc.asObservable()

    constructor(private http: HttpClient, private router: Router) {}

    getToken() {
        return this.token || (this.token = localStorage.getItem('token'))
    }

    setToken(token) {
        this.token = token
        localStorage.setItem('token', token)
    }

    removeToken() {
        this.token = null
        localStorage.removeItem('token')
    }

    setUser(user) {
        this.userSrc.next({ ...user })
        this.userInstance = { ...user }
    }

    getUserInstance() {
        return this.userInstance
    }

    login(username: string, password: string) {
        return this.http
            .post<any>(`${this.api}/authentication/login`, {
                username,
                password,
            })
            .pipe(
                map((res: any) => {
                    if (res.data) {
                        this.setToken(res.data.token)
                        this.setUser(res.data.user)
                    }
                    return res.code === 0
                })
            )
    }

    logout(willNavigate = false) {
        // clear token remove user from local storage to log user out
        this.removeToken()
        this.userInstance = null
        if (willNavigate) this.goLogin()
        return false
    }

    isLoggedIn() {
        if (!!this.userInstance) return of(this.userInstance)
        // dung ham nay de han che truy xuat localstorage de tang performance
        const token = this.getToken()
        // neu chua cho token thi chac chan chua dang nhap
        if (!token) {
            this.logout()
            return of(null)
        }
        return this.http.post<any>(`${this.api}/authentication/verify-token`, {}).pipe(
            tap(
                // Log the result or error
                (res) => {
                    if (res.code !== 0) {
                        return this.logout()
                    }
                    this.setToken(token)
                    this.setUser(res.data.user)
                },
                (error) => this.logout()
            ),
            map((res: any) => this.userInstance)
        )
    }

    goHome() {
        this.router.navigate(['/home'])
    }

    goLogin() {
        this.router.navigate(['/login'])
    }

    goUnSupportedBrowser() {
        this.router.navigate(['/un-supported-browser'])
    }
}
