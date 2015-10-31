#lang racket/base

(provide presence/type)
(define (presence/type js)
  (hash-ref js 'type #f))

(provide presence/content)
(define (presence/content js)
  (hash-ref js 'content #f))

(provide presence/content/user-id)
(define (presence/content/user-id js)
  (hash-ref js 'user_id #f))

(provide presence/content/avatar-url)
(define (presence/content/avatar-url js)
  (hash-ref js 'avatar_url #f))

(provide presence/content/last-active-ago)
(define (presence/content/last-active-ago js)
  (hash-ref js 'last_active_ago #f))

(provide presence/content/presence)
(define (presence/content/presence js)
  (hash-ref js 'presence #f))

