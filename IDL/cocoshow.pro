;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro COCOSHOW, coco_data_rgb_int, quiet=quiet, current=current, dims=dims, name=name, filepath=filepath, filetype=filetype
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;	  COCOSHOW
;
; PURPOSE:
;	  Display and/or save a COCOPLOT image
;
; CATEGORY:
;	  COCOPLOT visualisation
;
; CALLING SEQUENCE:
;	  COCOSHOW, coco_data_rgb_int
;
; INPUTS:
;	  coco_data_rgb_int: 3D COCOPLOT RGB integer array of dimensions [nx, ny, 3]
;
; KEYWORD PARAMETERS:
;   quiet:        Do not pop-up display image. Defaults to not set.
;   current:      Flag to plot in current window. Defaults to not set.
;   dims:         Image dimensions for display. Defaults to [nx, ny] of
;                 input coco_datacube.
;   name:         String containing output file name, triggers save
;                 of image if present. Does noe require suffix.
;   filepath:     String containting filepath that will be added to name.
;   filetype:     String for output image file type. default = "png". Valid
;                 formats from IDL write image routine:
;                 "bmp","gif","jpeg","png","ppm","srf","tiff".
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

; displaying image
  ; Set up options for correct display
  if (keyword_set(quiet)) then option1=1 else option1=0
  if (keyword_set(name)) then option2=1 else option2=-1
  option=option1*option2
  case option of
     0: begin
     ; not quiet, therefore either display in a new or 
     ; the current window without /buffer option.
        if (n_elements(dims) eq 2) then begin   
           nx=dims[0]
           ny=dims[1]
        endif else begin
           sz=size(coco_data_rgb_int)
           nx=sz[1]
           ny=sz[2]
        endelse
        if (not keyword_set(current)) then begin
           w=WINDOW(DIMENSIONS=[nx,ny])
        endif
        temp_image=image(coco_data_rgb_int, IMAGE_DIMENSIONS=[nx,ny], POSITION=[0.0,0.0,1.0,1.0],/current)
     end
     1: begin
     ; quiet, but save required, therefore display in buffer
        if (n_elements(dims) eq 2) then begin   
           nx=dims[0]
           ny=dims[1]
        endif else begin
           sz=size(coco_data_rgb_int)
           nx=sz[1]
           ny=sz[2]
        endelse
        if (not keyword_set(current)) then begin
           w=WINDOW(DIMENSIONS=[nx,ny],/BUFFER)
        endif
        temp_image=image(coco_data_rgb_int, IMAGE_DIMENSIONS=[nx,ny], POSITION=[0.0,0.0,1.0,1.0],/current)
     end
     ; no save or display required, so no image
  endcase

;saving image
  if (keyword_set(name)) then begin
     the_image=temp_image.CopyWindow()
     fileloc=name
        if (keyword_set(filepath)) then fileloc=filepath+name
        if (not keyword_set(filetype)) then filetype="png"
        fileloc=fileloc+"."+filetype
  	write_image, fileloc, filetype, the_image
  endif
end
