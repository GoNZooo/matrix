#lang racket/base

(require racket/string

         "matrix-api/initial-sync.rkt"
         "matrix-api/room.rkt"
         "matrix-api/send.rkt"
         "matrix-api/state.rkt"
         "matrix-api/messages.rkt"
         "matrix-api/events.rkt")

(define (allowed-user? user-id room-id)
  (equal? "1"
          (hash-ref (get/state/room/id room-id
                                       "com.severnatazvezda.apibot.allowed"
                                       #:state-key (substring user-id 1))
                    'allowed
                    #f)))

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

(define (handler/not-found message)
  (void message))

(define (command/.ping message)
  (send/room/message/id (event/room-id message)
                        ".pong!"))

(define dispatch-hash/event
  `#hash(("m.room.message" . ,handler/m.room.message)))

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
  (main-loop))
