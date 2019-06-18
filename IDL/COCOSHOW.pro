;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function COCOSHOW, coco_data_rgb_int, quiet=quiet, current=current, dims=dims, filepath=filepath, name=name
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;	  COCOSHOW
;
; PURPOSE:
;	  Return and/or display and/or save a COCOPLOT image.
;
; CATEGORY:
;	  COCOPLOT visualisation
;
; CALLING SEQUENCE:
;	  Result = COCOSHOW(coco_data_rgb_int)
;
; INPUTS:
;	  coco_data_rgb_int: 3D COCOPLOT RGB image of dimensions [nx, ny, 3]
;
; KEYWORD PARAMETERS:
;	  rgbthresh:    Flag to apply saturation thresholding. Defaults to not set.
;   threshmethod: Scalar string specifying the Saturation thresholding method.
;                 Can be 'fraction', 'numeric' or 'percentile'. Defaults to not set.
;   quiet:        Do not pop-up display image. Defaults to not set.
;   current:      Flag to plot in current window. Defaults to not set.
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
;     Functions:  IMAGE(), WINDOW()
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
     sz=size(coco_data_rgb_int)
     nx=sz[1]
     ny=sz[2]
  endelse
  if keyword_set(quiet) then begin
     w=WINDOW(DIMENSIONS=[nx,ny],/BUFFER) 
  endif else begin
     if (not keyword_set(current)) then begin
        w=WINDOW(DIMENSIONS=[nx,ny])
     endif
  endelse
  temp_image=image(coco_data_rgb_int, IMAGE_DIMENSIONS=[nx,ny], POSITION=[0.0,0.0,1.0,1.0],/current)
  the_image=temp_image.CopyWindow()
  if (keyword_set(name)) then begin
      fileloc=name
  	if (keyword_set(filepath)) then fileloc=filepath+name
  	write_png, fileloc, the_image
  endif
  return, the_image
end
