#lang racket/base

(require gregor)

(provide logging-thread
         display-log
         ->log)

(define logging-thread (make-parameter #f))

(define (display-log)
  (define thread-message (thread-receive))
  (printf "[~a] ~a~n"
          (~t (now) "dd.MM.y HH:mm:ss")
          thread-message)
  (flush-output (current-output-port))
  (display-log))

(define (->log message)
  (thread-send (logging-thread)
               message))

