#lang racket/base

(require racket/string
         db
         
         "matrix-api/db-interface.rkt"
         "matrix-api/login.rkt"
         "matrix-api/initial-sync.rkt"
         "matrix-api/room.rkt"
         "matrix-api/send.rkt"
         "matrix-api/state.rkt"
         "matrix-api/messages.rkt"
         "matrix-api/events.rkt")

(define (allowed-user? user-id room-id)
  (define flag-value
    (hash-ref (get/state/room/id room-id
                                 "com.severnatazvezda.apibot.allowed"
                                 #:state-key (substring user-id 1))
              'allowed
              #f))

  (if (not flag-value)
    (priv-user? user-id)
    (equal? "1" flag-value)))

(define (allow-user user-id room-id)
  (set/state/room/id room-id
                     "com.severnatazvezda.apibot.allowed"
                     '#hash((allowed . "1"))
                     #:state-key (substring user-id 1))
  (send/room/message/id room-id
                        (format "User '~a' allowed bot use in room '~a'."
                                user-id room-id)))

(define (disallow-user user-id room-id)
  (set/state/room/id room-id
                     "com.severnatazvezda.apibot.allowed"
                     '#hash((allowed . "0"))
                     #:state-key (substring user-id 1))
  (send/room/message/id room-id
                        (format "User '~a' disallowed bot use in room '~a'."
                                user-id room-id)))

(define (handler/m.room.message message)
  (define uid (event/user-id message))
  (define rid (event/room-id message))
  (when (allowed-user? uid rid)
    (dispatch/command message)))

(define (inviter? user-id)
  (call-with-transaction
    db-conn
    (lambda ()
      (= 1
         (query-maybe-value
           db-conn
           "SELECT can_invite FROM inviters WHERE user_id = $1"
           user-id)))))

(define (priv-user? user-id)
  (call-with-transaction
    db-conn
    (lambda ()
      (query-maybe-value
        db-conn
        "SELECT user_id FROM privusers WHERE user_id = $1"
        user-id))))

(define (handler/m.room.member event)
  (cond
    [(and (equal? (event/state-key event)
                  (user-info/user-id (get/user-info)))
          (equal? (hash-ref (event/content event)
                            'membership)
                  "invite")
          (inviter? (event/user-id event)))
     (room/join/id (event/room-id event))]
    [else (void)]))

(define (handler/not-found message)
  (void message))

(define (command/.ping message)
  (send/room/message/id (event/room-id message)
                        ".pong!"))

(define dispatch-hash/event
  `#hash(("m.room.message" . ,handler/m.room.message)
         ("m.room.member" . ,handler/m.room.member)))

(define (dispatch/event event)
  (define handler
    (hash-ref dispatch-hash/event
              (event/type event)
              (lambda () void)))
  (handler event))

(define dispatch-hash/command
  `#hash((".ping" . ,command/.ping)))

(define (dispatch/command message)
  (define handler
    (hash-ref dispatch-hash/command
              (car (string-split (hash-ref (event/content message)
                                           'body)))
              (lambda () void)))
  (handler message))

(define (main-loop #:sleep-time [sleep-time 0.5])
  (for-each dispatch/event
            (message/chunks (get/events)))
  (sleep sleep-time)
  (main-loop))

(module+ main
  (define sync-data (get/initial-sync))

  (main-loop))
