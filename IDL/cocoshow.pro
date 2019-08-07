;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO COCOSHOW, coco_data_rgb_int, QUIET=quiet, CURRENT=current, DIMS=dims, NAME=name, FILEPATH=filepath, FILETYPE=filetype
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
;   QUIET:        Do not pop-up display image. Defaults to not set.
;   CURRENT:      Flag to plot in current window. Defaults to not set.
;   DIMS:         Image dimensions for display. Defaults to [nx, ny] of
;                 input coco_datacube.
;   NAME:         String containing output file name, triggers save
;                 of image if present. Does noe require suffix.
;   FILEPATH:     String containting filepath that will be added to name.
;   FILETYPE:     String for output image file type. default = "png". Valid
;                 formats from IDL write image routine:
;                 "bmp","gif","jpeg","png","ppm","srf","tiff".
;
; OUTPUTS:
;   Displayed and/or saved COCOPLOT image.
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
;   Written by: Malcolm Druett & Gregal Vissers, May-August 2019
;-

  IF (N_PARAMS() LT 1) THEN BEGIN
    MESSAGE, 'Syntax: COCOSHOW, coco_data_rgb_int [, /QUIET] [, /CURRENT] '+$
      '[, DIMS=dims] [, NAME=name] [, FILEPATH=filepath] '+$
      '[, FILETYPE=filetype]', /INFO
    RETURN
  ENDIF

  IF (N_ELEMENTS(DIMS) NE 2) THEN dims = (SIZE(coco_data_rgb_int))[1:2]

  ; Create image if save or display requested 
  IF (N_ELEMENTS(NAME) EQ 1) OR (NOT KEYWORD_SET(QUIET)) THEN BEGIN
    IF NOT KEYWORD_SET(CURRENT) THEN $
      w = WINDOW(DIMENSIONS=dims, BUFFER=KEYWORD_SET(QUIET))
    temp_image = IMAGE(coco_data_rgb_int, IMAGE_DIMENSIONS=dims, POSITION=[0.0,0.0,1.0,1.0], /CURRENT)
    ; Save image if output filename supplied
    IF (N_ELEMENTS(NAME) EQ 1) THEN BEGIN
      the_image=temp_image.CopyWindow()
      fileloc=name
      IF (N_ELEMENTS(FILEPATH) EQ 1) THEN fileloc=filepath+name
      IF (N_ELEMENTS(FILETYPE) NE 1) THEN filetype="png"
      fileloc=fileloc+"."+filetype
      WRITE_IMAGE, fileloc, filetype, the_image
    ENDIF
  ENDIF
END
