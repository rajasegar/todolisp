(defpackage :todo
  (:use :cl :cl-who :hunchentoot :parenscript))

(in-package :todo)

(defclass todo ()
  ((name :reader name
         :initarg :name)
   (done :accessor done
         :initform nil)))

(defvar *todolist* '())

(defun add-todo (name)
  (push (make-instance 'todo :name name) *todolist*))

(defun todo-from-name (name)
  (find name *todolist* :test #'string-equal :key #'name))

(defun todo-stored? (name)
  (todo-from-name name))

(setf (html-mode) :html5)

(defmacro todo-page ((&key title script) &body body)
  `(with-html-output-to-string
     (*standard-output* nil :prologue t :indent t)
        (:html :lang "en"
               (:head
                 (:meta :charset "utf-8")
                 (:title, title)
                 (:link 
                   :type "text/css" 
                   :rel "stylesheet" 
                   :href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css")
                 ,(when script
                    `(:script :type "text/javascript" (str ,script))))
               (:body
                 (:div :class "container"
                       (:div :class "row"
                             (:div :class "col-md-12"
                                (:br)
                                (:div :class "jumbotron"
                                   (:h1 "Todo,Lisp!")
                ,@body))))))))

(defun start-server (port)
  (start (make-instance 'easy-acceptor :port port)))

(define-easy-handler (app :uri "/") () 
    (redirect "/todo"))

(define-easy-handler (todo :uri "/todo") ()
    (todo-page (:title "TodoList"
                :script (ps ; console.log
                          (chain console (log "Hello"))) )
               (:h4 :class "text-right" "Total items:" (:span (fmt  "~A" (list-length *todolist*))))
               (:ol
                   (dolist (item *todolist*)
                     (htm
                           (:li 
                             (fmt  "~a" (name item))
                             (:a :class "text-danger" :href (format nil "/todo/delete?name=~a" (url-encode (name item)))  "Delete")))))
               (:form :class "form" :action "/todo-added" :method "post"
                      (:p "Add a new task:"
                          (:input :class "form-control" :type "text" :name "name"))
                      (:p :class "text-right" 
                        (:input  :type "submit" :value (format nil "Add Todo #~d" (+ 1 (list-length *todolist*))) :class "btn btn-primary btn-lg")))))

(define-easy-handler (todo-added :uri "/todo-added") (name)
    (unless (or (null name) (zerop (length name)))
      (add-todo name))
    (redirect "/todo"))

(define-easy-handler (todo-delete :uri "/todo/delete") (name)
    ; delete the item here
    (setf *todolist* (remove (todo-from-name name) *todolist*))
    (redirect "/todo"))

(start-server 3000)
