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
