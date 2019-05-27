#lang racket
 
(require web-server/servlet)
(require xml)
(provide/contract (start (request? . -> . response?)))

; retrieved from: https://docs.racket-lang.org/continue/
; servelt changes made from: https://docs.racket-lang.org/continue/#%28part._.Moving_.Forward%29

(define (page page-head page-body)
  `(html
    (head
     ,@page-head)
    (body
     ,@page-body)))

(define style
  "
body {
  background-color: magenta;
}

#post-list {
  list-style: none;
}

.post {
  border-style: solid;
  margin-bottom: 3%;
  padding-left: 1%;
  padding-bottom: 1%;
}
")

(define default-head
  `(
    (title "My Site")
    (style ,style)))

(define (default-with-body body)
  (page default-head body))

(define (header heading)
  `(center
    (h1 [(style "color:blue")] ,heading)
    (hr)))

(define (post title content)
  `(div [(class "post")]
        (h2 ,title)
        ,@content))

(define (blog posts) (default-with-body
  `(,(header "My Blog")
    (div [(id "posts")]
         (ul [(id "post-list")]
             ,@(map (λ (post) `(li ,post)) posts))))))


(define blog-posts
  (list
   (post "First Post" '("Just some text"))
   (post "Second Post" '((p "A proper paragraph " (em "this") " time!")))))

(define index (default-with-body
              `(,(header "Welcome!")
                (p "TODO: put something here"))))

(define error-page (default-with-body
                     `(,(header "Something went wrong!"))))

(define blog-page (blog blog-posts))

(define (select-page path)
  (match path
    [(list (path/param "" _)) index]
    [(list (path/param "index" _)) index]
    [(list (path/param "blog" _)) blog-page]
    [_ error-page]))

(define parse-request
  (compose
   select-page
   url-path
   request-uri))

(define (start request)
  (response/xexpr
   (parse-request request)))


(require web-server/servlet-env)
(serve/servlet start
               #:launch-browser? #f
               #:quit? #f
               #:listen-ip #f
               #:port 3000
               #:servlet-regexp #rx"")
