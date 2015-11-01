#lang racket/base

(provide message/chunks)
(define (message/chunks js)
  (hash-ref js 'chunk #f))

(provide message/start)
(define (message/start js)
  (hash-ref js 'start #f))

(provide message/end)
(define (message/end js)
  (hash-ref js 'end #f))

