#lang racket/base

(require db
         gonz/with-matches

         "matrix-api/events.rkt"
         "matrix-api/db-interface.rkt"
         "matrix-api/send.rkt"
         "matrix-api/room.rkt"
         "datetime-parsing.rkt")

(provide reminder/user)
(define (reminder/user r)
  (vector-ref r 0))

(provide reminder/place)
(define (reminder/place r)
  (vector-ref r 1))

(provide reminder/datetime)
(define (reminder/datetime r)
  (vector-ref r 2))

(provide reminder/text)
(define (reminder/text r)
  (vector-ref r 3))

(provide reminder/id)
(define (reminder/id r)
  (vector-ref r 4))

(provide db/get/reminders)
(define (db/get/reminders)
  (call-with-transaction
    db-conn
    (lambda ()
      (query-rows
        db-conn
        (string-append "SELECT *,rowid FROM reminders WHERE datetime LIKE "
                       "strftime('%Y-%m-%d %H:%M:00', 'now', 'localtime')")))))

(provide db/add/reminder)
(define (db/add/reminder user place datetime text)
  (call-with-transaction
    db-conn
    (lambda ()
      (query-exec
        db-conn
        "INSERT INTO reminders values ($1, $2, $3, $4)"
        user place (bg-time->sql-time datetime) text))
    #:option 'immediate
    #:isolation 'read-uncommitted))

(define (db/remove/reminder reminder-id)
  (call-with-transaction
    db-conn
    (lambda ()
      (query-exec
        db-conn
        "DELETE FROM reminders WHERE rowid = $1"
        (reminder/id reminder-id)))
    #:option 'immediate
    #:isolation 'read-uncommitted))

(provide db/remove/reminders)
(define (db/remove/reminders reminder-ids)
  (map db/remove/reminder reminder-ids))

(provide reminder/notify)
(define (reminder/notify reminder)
  (define place (reminder/place reminder))
  (send/room/message/id
    (if (equal? place
                "priv")
      (hash-ref (room/create/private `(,(reminder/user reminder))
                                     "api-bot reminder")
                'room_id)
      place)
    (format "~a: Reminder - ~a"
            (reminder/user reminder)
            (reminder/text reminder))))

(provide parse/remind/parameters)
(define (parse/remind/parameters message)
  (define message-content (hash-ref (event/content message)
                                    'body))
  (define user-regex "@[A-Za-z0-9-]*:[a-z]*\\.[a-z]*|me")
  (define place-regex "here|priv")
  (define datetime-regex "\\d\\d.\\d\\d.\\d\\d \\d\\d:\\d\\d")

  (define command-regex
    (pregexp (format "~a ~a ~a"
                     user-regex
                     place-regex
                     datetime-regex)))
  (if (regexp-match? command-regex
                     message-content)
    (let*-values
      ([(extraction-regex)
        (pregexp (format ".remind (~a) (~a) (~a) (.*)"
                         user-regex
                         place-regex
                         datetime-regex))]
       [(user place datetime text)
        (with-matches extraction-regex
                      message-content
                      (values (m 1) (m 2) (m 3) (m 4)))])
      (define param-user (if (equal? user "me")
                           (event/user-id message)
                           user))
      (define param-place
        (if (equal? place "here")
          (event/room-id message)
          "priv"))

      (define param-datetime (parse/datetime/absolute/bg datetime))
      (values param-user param-place param-datetime text))
    (values #f #f #f #f)))

