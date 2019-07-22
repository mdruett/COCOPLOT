;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function COCOIMAGE, coco_datacube, filter, rgbthresh=rgbthresh, threshmethod=threshmethod, quiet=quiet, dims=dims, filepath=filepath, name=name, current=current
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;	  COCOIMAGE
;
; PURPOSE:
;	  Return and/or display and/or save a COCOPLOT image.
;
; CATEGORY:
;	  COCOPLOT visualisation
;
; CALLING SEQUENCE:
;	  Result = COCOIMAGE(coco_datacube, filter)
;
; INPUTS:
;	  coco_datacube:  Input data cube of dimensions [nx, ny, nWavelengths]
;   filter:         Filter of dimensions [nWavelengths, 3] 
;
; KEYWORD PARAMETERS:
;	  rgbthresh:    Flag to apply saturation thresholding. Defaults to not set.
;   threshmethod: Scalar string specifying the Saturation thresholding method.
;                 Can be 'fraction', 'numeric' or 'percentile'. Defaults to not set.
;   quiet:        Do not pop-up display image. Defaults to not set.
;   dims:         image dimensions for display. Defaults to [nx, ny] of
;                 input coco_datacube.
;   filepath:     Output path.
;   name:         Output file name.
;
; OUTPUTS:
;	  Return and/or display and/or save a COCOPLOT image.
;
; RESTRICTIONS:
;   Requires the following procedures and functions:
;     Procedures: WRITE_PNG
;     Functions: COCOPLOT(), IMAGE(), WINDOW()
;
; EXAMPLE:
;   TBD
;
; MODIFICATION HISTORY:
; 	Written by:	Malcolm Druett, May 2019
;-
  if (n_elements(dims) eq 2) then begin 
     nx=dims[0]
     ny=dims[1]
  endif else begin
     sz=size(coco_datacube)
     nx=sz[1]
     ny=sz[2]
  endelse
  if (not keyword_set(current)) then w = WINDOW(DIMENSIONS=[nx,ny], BUFFER=keyword_set(quiet))
  temp_image=image(COCOPLOT(coco_datacube, filter, rgbthresh=rgbthresh, threshmethod=threshmethod), $
    IMAGE_DIMENSIONS=[nx,ny], POSITION=[0.0,0.0,1.0,1.0],/current)
  the_image=temp_image.CopyWindow()
  if (keyword_set(name)) then begin
      fileloc=name
  	if (keyword_set(filepath)) then fileloc=filepath+name
  	write_png, fileloc, the_image
  endif
  return, the_image
end
