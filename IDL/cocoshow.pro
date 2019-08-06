;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO COCOSHOW, coco_data_rgb_int, quiet=quiet, current=current, dims=dims, name=name, filepath=filepath, filetype=filetype
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;   COCOSHOW
;
; PURPOSE:
;   Display and/or save a COCOPLOT image.
;
; CATEGORY:
;   COCOPLOT visualisation
;
; CALLING SEQUENCE:
;   COCOSHOW, coco_data_rgb_int
;
; INPUTS:
;   coco_data_rgb_int: 3D COCOPLOT RGB integer array of dimensions [nx, ny, 3].
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
;   Return and/or display and/or save a COCOPLOT image.
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
;   Written by: Malcolm Druett, May 2019
;-

  ; displaying image.
  ; Set up options for correct display.
  IF (KEYWORD_SET(quiet)) THEN option1=1 ELSE option1=0
  ; save required, therefore display in buffer if not actually displaying.
  IF (KEYWORD_SET(name)) THEN BEGIN
    IF (N_ELEMENTS(dims) EQ 2) THEN BEGIN
      nx=dims[0]
      ny=dims[1]
    ENDIF ELSE BEGIN
      sz=size(coco_data_rgb_int)
      nx=sz[1]
      ny=sz[2]
    ENDELSE
    IF (NOT KEYWORD_SET(current)) THEN BEGIN
      w=WINDOW(DIMENSIONS=[nx,ny],BUFFER=option)
    ENDIF
    temp_image=image(coco_data_rgb_int, IMAGE_DIMENSIONS=[nx,ny], POSITION=[0.0,0.0,1.0,1.0],/CURRENT)
  ENDIF ELSE BEGIN
  ; No save required, show only if quiet not set.
    IF (option=0) THEN BEGIN
      IF (N_ELEMENTS(dims) EQ 2) THEN BEGIN
        nx=dims[0]
        ny=dims[1]
      ENDIF ELSE BEGIN
        sz=SIZE(coco_data_rgb_int)
        nx=sz[1]
        ny=sz[2]
      ENDELSE
      IF (NOT KEYWORD_SET(current)) THEN BEGIN
        w=WINDOW(DIMENSIONS=[nx,ny])
      ENDIF
      temp_image=image(coco_data_rgb_int, IMAGE_DIMENSIONS=[nx,ny], POSITION=[0.0,0.0,1.0,1.0],/CURRENT)
    ENDIF ELSE BEGIN
     ; quiet set and no save required, skip display.
        RETURN
    ENDELSE
     ; no save or display required, so no image.
  ENDELSE
  ;saving image.
  IF (KEYWORD_SET(name)) THEN BEGIN
     the_image=temp_image.CopyWindow()
     fileloc=name
        IF (KEYWORD_SET(filepath)) THEN fileloc=filepath+name
        IF (NOT KEYWORD_SET(filetype)) THEN filetype="png"
        fileloc=fileloc+"."+filetype
    WRITE_IMAGE, fileloc, filetype, the_image
  ENDIF
END
