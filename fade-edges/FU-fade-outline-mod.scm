; FU_edges_fade-outline.scm
; version 2.0 [gimphelp.org]
; last modified/tested by Paul Sherman
; 01/02/2011 on GIMP-2.6.11
;
; 10/17/2010 - fixed undefined variable (l-orig-selection)
; when using a growing selection.  Discovered and
; corrected by John McGowan <jmcgowan@inch.com>
; ------------------------------------------------------------------
; Original information ---------------------------------------------
; 
; This GIMP script_fu operates on a single Layer
; It blends the outline boarder from one to another transparency level
; by adding a layer_mask that follows the shape of the selection.
; usually from 100% (white is full opaque) to 0% (black is full transparent)
;
; The user can specify the thickness of the fading border
; that is used to blend from transparent to opaque
; and the Fading direction (shrink or grow).
;
; The outline is taken from the current selection
; or from the layers alpha channel if no selection is active.
;
; Optional you may keep the generated layermask or apply
; it to the layer 
;
; Tue 10/14/2008 - Modified by Paul Sherman
;     Eliminated undefined variable errors.
;     Simplified by flattening image upon completion.
;     Added option to leave fade transparent, or flaten onto the image.
;
;
; The GIMP -- an image manipulation program
; Copyright (C) 1995 Spencer Kimball and Peter Mattis
; 
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;
; End original information ------------------------------------------
;--------------------------------------------------------------------

(define (FU-fade-outline-mod image drawable inBorderSize)



			; check Fade from and To Values (and force values from 0% to 100%)
			(define inFadeFrom 100 ) 
			(define inFadeTo 0 )
(define l-from-gray (* inFadeFrom 255))
(define l-to-gray (* inFadeTo 255))
				(define l-step (/  (- l-from-gray l-to-gray) (+ inBorderSize 1)))
				(define l-gray l-to-gray)
			(define l-orig-selection)

	(let* ((layers (gimp-image-get-layers image))
		(layers_num (car layers))
		(layers_array (cadr layers))
		(i (- layers_num 1)))
		(while (>= i 0)

		(set! l-gray l-to-gray)

		(let* ((inLayer (aref layers_array i))
			(l-mask (car (gimp-layer-create-mask inLayer BLACK-MASK)))) 
		
(gimp-undo-push-group-start image)

			(let* ((l-idx 0)
				(l-old-bg-color (car (gimp-palette-get-background)))
				(l-has-selection FALSE)
			)
				          
					(if (= (car (gimp-drawable-has-alpha inLayer)) FALSE)
							(gimp-layer-add-alpha inLayer))

							(gimp-selection-layer-alpha inLayer)

					(gimp-image-add-layer-mask image inLayer l-mask)                   
									                   
				          (while (<= l-idx inBorderSize)
				             (if (= l-idx inBorderSize)
				                 (begin
				                   (set! l-gray l-from-gray)
				                  )
				              )
				              (gimp-palette-set-background (list (/ l-gray 100) (/ l-gray 100) (/ l-gray 100)))
				              (gimp-edit-fill l-mask BG-IMAGE-FILL)
				              (set! l-idx (+ l-idx 1))
				              (set! l-gray (+ l-gray l-step))
				              (gimp-selection-shrink image 1)
				              ; check if selection has shrinked to none
				              (if (= (car (gimp-selection-is-empty image)) TRUE)
				                  (begin
				                     (set! l-idx (+ inBorderSize 100))     ; break the while loop
				                  )
				               )

				          )



				              (gimp-image-remove-layer-mask image inLayer 0)

              (if (= l-has-selection FALSE)
                  (gimp-selection-none image)
              )
				         )

(gimp-undo-push-group-end image)
				    )
				(set! i (- i 1))

				
			)
	)

					
				         (gimp-displays-flush)

)

(script-fu-register
    "FU-fade-outline-mod"
    "Fade Outline Mod"
    "Blend all Layers outline border from one alpha value (opaque) to another (transparent) by generating a Layermask"
    "Wolfgang Hofer <hof@hotbot.com>"
    "Wolfgang Hofer"
    "10 Nov 1999"
		""
		SF-IMAGE    "SF-IMAGE" 0
		SF-DRAWABLE "SF-DRAWABLE" 0
    SF-ADJUSTMENT _"Border Size" '(10 1 300 1 10 0 1)
)
(script-fu-menu-register "FU-fade-outline-mod" "<Image>/Script-Fu/Edges/")
