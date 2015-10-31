#lang racket/base

(provide chunk/type)
(define (chunk/type js)
  (hash-ref js 'type #f))

(provide chunk/user-id)
(define (chunk/user-id js)
  (hash-ref js 'user_id #f))

(provide chunk/content)
(define (chunk/content js)
  (hash-ref js 'content #f))

(provide chunk/content/body)
(define (chunk/content/body js)
  (hash-ref js 'body #f))

(provide chunk/content/msgtype)
(define (chunk/content/msgtype js)
  (hash-ref js 'msgtype #f))

(provide chunk/age)
(define (chunk/age js)
  (hash-ref js 'age #f))

(provide chunk/event-id)
(define (chunk/event-id js)
  (hash-ref js 'event_id #f))

(provide chunk/origin-server-ts)
(define (chunk/origin-server-ts js)
  (hash-ref js 'origin_server_ts #f))

(provide chunk/room-id)
(define (chunk/room-id js)
  (hash-ref js 'room_id #f))

