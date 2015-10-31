#lang racket/base

(provide room/room-id)
(define (room/room-id js)
  (hash-ref js 'room_id #f))

(provide room/membership)
(define (room/membership js)
  (hash-ref js 'membership #f))

(provide room/messages)
(define (room/messages js)
  (hash-ref js 'messages #f))

(provide room/states)
(define (room/states js)
  (hash-ref js 'state #f))

(provide room/visibility)
(define (room/visibility js)
  (hash-ref js 'visibility #f))

