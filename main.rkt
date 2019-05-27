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
  padding-right: 1%;
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
   (post "Third Post"
         '((p "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec sed nibh enim. Fusce sit amet purus quis felis dapibus ultricies. Sed eget dui egestas, tempus ex sagittis, dapibus justo. Aliquam sollicitudin nulla id nisi euismod, vel bibendum turpis ultrices. Aliquam erat volutpat. Mauris imperdiet consequat augue eget mollis. Proin quis massa nisl. Duis sagittis ante non metus sagittis, at semper sapien pellentesque. Sed tempor efficitur magna quis rutrum. Duis a elit vitae magna tincidunt consectetur nec vitae tellus. Sed fringilla volutpat elit, ut facilisis ante tincidunt sit amet. Vestibulum ultrices orci vitae justo molestie, eu dignissim sem semper. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent eget nunc a velit gravida tristique. Sed elementum vulputate quam ac mattis. Maecenas imperdiet ipsum non dui porta aliquet.")
           (p "Nulla imperdiet sollicitudin vehicula. Sed et neque sodales, accumsan nibh ut, vestibulum dolor. Nullam non erat quis nisl tristique semper. Ut ac sem ex. Praesent dignissim neque et rutrum euismod. Vivamus commodo metus vulputate nisl rhoncus, at mattis quam sagittis. Mauris semper metus in vulputate molestie. Donec maximus vel nibh quis euismod. Pellentesque neque diam, lobortis fermentum quam quis, tempus bibendum neque. In non sem efficitur, pretium libero non, finibus eros. Vestibulum eu sagittis purus. Donec suscipit et quam eu semper. Vestibulum eu bibendum dolor. Praesent quis vulputate neque, a tincidunt augue.")
           (p "Proin sit amet orci ut lectus pharetra ultricies. In sed orci sit amet eros blandit laoreet. Nullam eleifend ac lectus non bibendum. Nulla facilisi. Donec in dui hendrerit, fermentum justo id, auctor augue. Proin eu est ut elit ultrices iaculis vitae feugiat massa. Curabitur eget enim rhoncus ante scelerisque finibus ac quis sapien. Praesent ac vehicula leo, ut ullamcorper tortor. Proin vel nulla quis velit faucibus tincidunt vel id odio. Pellentesque at justo a dui aliquam cursus. Integer ut elit sit amet leo accumsan varius. Phasellus feugiat nulla suscipit sapien condimentum interdum. Ut nec lorem vitae dolor cursus convallis. Vivamus mi tellus, pharetra a libero a, rhoncus consequat orci. Nullam et accumsan eros, id aliquet nisl. Nulla consectetur iaculis mauris, a tincidunt dui gravida eu.")
           (p "Maecenas at nisi et nunc pellentesque vulputate. Donec quis ex tincidunt massa malesuada sollicitudin. Pellentesque orci orci, vehicula vitae odio iaculis, finibus eleifend arcu. Nam hendrerit, mi at aliquet iaculis, enim lorem malesuada mauris, quis rutrum ex massa nec arcu. Sed non diam tortor. Proin scelerisque purus eget felis laoreet viverra. Aenean id lacus ornare, efficitur ante a, tempus ligula. Pellentesque gravida turpis posuere arcu placerat, id facilisis erat scelerisque. Praesent ultricies turpis at leo auctor sagittis.")
           (p "Mauris ac pellentesque augue. Donec condimentum ut ex nec tempus. Etiam ac odio lobortis, hendrerit ipsum at, eleifend odio. Praesent facilisis commodo metus a rhoncus. Donec sit amet vulputate arcu, in imperdiet purus. Aenean eget tellus sodales, bibendum velit in, faucibus tellus. Maecenas viverra, enim ut sodales feugiat, tortor ante pellentesque turpis, et mollis nulla tortor vitae ipsum. Etiam vel mollis dui, vitae facilisis orci. Sed rutrum nulla et tempus ullamcorper. In volutpat ut erat posuere aliquam. Etiam vestibulum, enim vel pretium aliquet, leo augue consequat arcu, a cursus mi dui in erat. Suspendisse et auctor odio. Integer convallis, mi sit amet dignissim accumsan, augue massa tempus urna, vitae aliquam nisi justo ac tortor. Nam laoreet nulla iaculis ex elementum gravida.")
           (span [(style "color:red")] (p "Now that's a lot of " (strong "text")))))
   (post "Second Post" '((p "A proper paragraph " (em "this") " time!")))
   (post "First Post" '("Just some text"))))

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
