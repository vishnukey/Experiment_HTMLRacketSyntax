#lang racket

;; Resources:
;     https://docs.racket-lang.org/continue/
;     https://docs.racket-lang.org/continue/#%28part._.Moving_.Forward%29

(require web-server/servlet web-server/servlet-env)

; All the boiler play of an html page
; Might work better a macro, wouldn't
; need to pass in symbols that way
(define (page page-head page-body)
  `(html
    (head
     ,@page-head)
    (body
     ,@page-body)))

; Mainly for testing
; It'd be nice if we could build some good
; syntactic abstractions for style too
(define style
  "
body {
  background-color: white;
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

; Reusing the head of pages for consistent styling??
; unheard of
(define default-head
  `(
    (title "My Site")
    (style ,style))) ; insert the style "sheet"

(define (default-with-body body)
  (page default-head body))

; Headers are nice. This just gives a blue
; Centred heading with a horizontal rule
; afterwards
(define (header heading)
  `(center
    (h1 [(style "color:blue")] ,heading) ; insert text for heading
    (hr)))

; Getting to the fancy stuff here
; Describes a blog post. Who needs
; element templates when you have
; strong enough syntax
(define (post title content)
  `(div [(class "post")]
        (h2 ,title)
        ,@content)) ; insert content, and let it be it's own tree of elements

; The real big guns, rendering page with a list
; of blog posts given a (list) of blog posts
; Starting to look suscipiciously like a macro here
(define (blog posts) (default-with-body
  `(,(header "My Blog")
    (div [(id "posts")]
         (ul [(id "post-list")]
             ,@(map (λ (post) `(li ,post)) posts))))))

; Some actual data to work off of
(define blog-posts
  (list
   (post "First Post" '("Just some text"))
   (post "Second Post" '((p "A proper paragraph " (em "this") " time!")))))

; The landing page
(define index (default-with-body
              `(,(header "Welcome!")
                (p "TODO: put something here"))))

; When things go wrong
(define error-page (default-with-body
                     `(,(header "Something went wrong!"))))

; The page of blog posts. Dynamically generated
(define blog-page (blog blog-posts))

; pattern matching on the url, including parameters
(define (select-page path)
  (match path
    [(list (path/param "" _)) index]
    [(list (path/param "index" _)) index] ; two endpoints to the same page
    [(list (path/param "blog" _)) blog-page]
    [_ error-page]))

; Takes a request and turns it into a page, more or less
; runs functions from last to first
(define parse-request
  (compose
   select-page
   url-path
   request-uri))

; main response handler
; actually sends the responds to a request
(define (start request)
  (response/xexpr
   (parse-request request)))

; Make it a server
(serve/servlet start
               #:launch-browser? #f
               #:quit? #f
               #:listen-ip #f
               #:port 3000
               #:servlet-regexp #rx"") ; capture all urls, allows for pattern matching later
