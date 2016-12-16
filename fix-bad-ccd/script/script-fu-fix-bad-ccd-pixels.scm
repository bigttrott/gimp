(define (script-fu-fix-bad-ccd-pixels pattern selectionLayerFileName)
        ;(gimp-message pattern) 
  (let* ((filelist (cadr (file-glob pattern 1))))
    (while (not (null? filelist))
      (let* (
            (filename (car filelist))
            (image (car (gimp-file-load RUN-NONINTERACTIVE filename filename)))
            (drawable (car (gimp-image-get-active-layer image)))
            ; Open bad ccd pixel image
            (loadedLayer (car (gimp-file-load-layer RUN-NONINTERACTIVE image selectionLayerFileName)))
            )
		(gimp-image-insert-layer image loadedLayer 0 -1)
		;(gimp-message-set-handler 2)
		;(gimp-message selectionLayerFileName) 		
        ;(gimp-message (string-append (car (gimp-image-get-filename image)))) 
        (gimp-image-select-item image 0 loadedLayer)

        (let* (
              (resultingLayer (car (gimp-image-merge-visible-layers image 1)))
              )

          (set! drawable (car (gimp-image-get-active-layer image)))

          ; run the heal selection python-fu plugin with radius 3, pixel data from all sides, and fill in randomly
          (python-fu-heal-selection RUN-NONINTERACTIVE image drawable 3 0 0)
          (gimp-selection-none image)
          (file-tiff-save RUN-NONINTERACTIVE image drawable filename filename 0)
        )
        
        (gimp-image-delete image)
      )
      (set! filelist (cdr filelist))
    )
  )
)

;(script-fu-register "script-fu-fix-bad-ccd-pixels"
;                    "<Image>/Filters/Enhance/Fix CCD Pix..."
;                    "Loops through layers healing selection (bad pixels)"
;                    "Solar Anamnesis <ttrott@tutanota.com>"
;                    "Solar Anamnesis"
;                    "2016/12/12"
;                    "*"
;                    SF-IMAGE "Image" 0
;                    SF-DRAWABLE "Drawable" 0
;					SF-STRING "Alpha Selection Layer Name" "Text")
(define (do-it-real file-names-list)
  ; If you have any preprocessing to do, that is needed for all the images, do
  ; it here. For example, if the image is an ordered list of movie frames, you
  ; may want to define a counter starting at 0 here, and then access it later
  ...

  ; Now, run through the list of images
  (map
    ; For each file name, do the following
    (lambda (file-name)
      (let* (
             ; Load the image, and retrieve it's ID into this variable
             (image (car (gimp-file-load RUN-NONINTERACTIVE file-name file-name)))

             ; In many cases, we want the ID of the top layer (especially in
             ; images which have one layer; in these cases that layer has the
             ; actual image data.
             (layer (vector-ref (cadr (gimp-image-get-layers image)) 0))

             ; Get the name of the image (without the folder path, just the
             ; name of the image file). Useful if you want to save the image at
             ; a different folder or with a slightly modified name.
             (image-name (car (gimp-image-get-name image)))
            )

            ; Do some stuff to the image
            ...

            ; Save the image using the default saving method. We pass the same
            ; file name to override the source.
            (gimp-file-save RUN-NONINTERACTIVE image layer file-name file-name)

            ; Important - Close the image! Don'e just waste memory on hidden
            ; images. Also the idea is to work on one image at a time.
            (gimp-image-delete image)
        )
      )
    file-names-list
    )
  )

; This procedure takes a pattern describing the names of the images to be
; processed. Examples:
;
;   "/home/lightning/Desktop/hello*.png"
;     All files on my Desktop folder, which are of png type and their name
;     begin with the world hello
;
;   "/home/lightning/Pictures/*"
;     All files inside my pictures folder
;
; Notes:
;
; 1. On Windows, if your path is of the form "C:\gimp\hi.emf", make sure you
;    change it to have double-backslashes: "C:\\gimp\\hi.emf"
;
; 2. The variable DIR-SEPARATOR contains the folder seperator charcter for the
;    given platform ('/' on Linux/Unix, '\' on Windows). Could be used in
;    (string-append FOLDER-PATH DIR-SEPARATOR FILE-NAME) to create a new path,
;    possibly for saving a file in a different directory.
;
; Example invocation:
;
;    (do-it "/home/lightning/tutorial/figure*.png")
(define (do-it file-name-pattern)
  (do-it-real (cadr (file-glob file-name-pattern 1))))