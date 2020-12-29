import { Injectable } from '@angular/core'
import {
    HttpEvent,
    HttpInterceptor,
    HttpHandler,
    HttpRequest,
    HttpResponse,
    HttpErrorResponse,
} from '@angular/common/http'

import { finalize, tap } from 'rxjs/operators'
import { AuthService } from '@app/auth/auth.service'

@Injectable()
export class LoggingInterceptor implements HttpInterceptor {
    constructor(private auth: AuthService) {}

    intercept(req: HttpRequest<any>, next: HttpHandler) {
        // const started = Date.now()
        let r: any

        // extend server response observable with logging
        return next.handle(req).pipe(
            tap(
                // Succeeds when there is a response ignore other events
                (event) => (r = (event instanceof HttpResponse && event) || r),
                // Operation failed error is an HttpErrorResponse
                (error) => (r = error)
            ),
            // Log when response observable either completes or errors
            finalize(() => {
                // const elapsed = Date.now() - started
                // const msg = `${req.method} "${req.urlWithParams}"
                //    ${ok} in ${elapsed} ms.`
                // console.log(msg)
                if (r instanceof HttpErrorResponse && r.status === 401)
                    this.auth.logout(true)
            })
        )
    }
}
