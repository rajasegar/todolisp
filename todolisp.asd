(asdf:defsystem #:todolisp
    :serial t
    :description "TodoList application in Common Lisp"
    :depends-on (#:cl-who
                #:hunchentoot
                #:parenscript)
    :components ((:file "package")
		 (:file "application")
		 ))
