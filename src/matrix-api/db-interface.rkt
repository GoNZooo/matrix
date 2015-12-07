#lang racket/base

(require db
         
         "db-credentials.rkt")

(provide db-conn)
(define db-conn
  (virtual-connection
   (connection-pool
    (lambda ()
      (sqlite3-connect #:database sqlite3-db/path
                       #:mode 'read/write)))))
