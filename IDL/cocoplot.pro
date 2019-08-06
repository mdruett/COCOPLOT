;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION COCOPLOT, coco_datacube, FILTER=filter, RGBTHRESH=rgbthresh, THRESHMETHOD=threshmethod, QUIET=quiet, CURRENT=current, DIMS=dims, NAME=name, FILEPATH=filepath, FILETYPE=filetype
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;   COCOPLOT
;
; PURPOSE:
;   Apply filter to 3D datacube and return COCOPLOT RGB integer array.
;
; CATEGORY:
;   COCOPLOT core
;
; CALLING SEQUENCE:
;   Result = COCOPLOT(coco_datacube, filter=myfilter)
;
; INPUTS:
;   coco_datacube:  Input data cube of dimensions [nx, ny, nspect_points],
;                   Or RGB cube [nx, ny, 3] if no filter is supplied.
;
; KEYWORD PARAMETERS:
;   FILTER:         Filter of dimensions [nspect_points, 3] specifying
;                   values used to color collpase the datacube.
;   RGBTHRESH:      Flag to apply saturation thresholding. Defaults to not set.
;   THRESHMETHOD:   Scalar string specifying the Saturation thresholding method.
;                   Can be 'fraction', 'numeric' or 'percentile'. Defaults to not set.
;   QUIET:          Do not pop-up display image. Defaults to not set.
;   CURRENT:        Flag to plot in current window. Defaults to not set.
;   DIMS:           Image dimensions for display. Defaults to [nx, ny] of
;                   input coco_datacube.
;   NAME:           String containing output file name, triggers save
;                   of image if present. Does noe require suffix.
;   FILEPATH:       String containting filepath that will be added to name.
;   FILETYPE:       String for output image file type. default = "png". Valid
;                   formats from IDL write image routine:
;                   "bmp","gif","jpeg","png","ppm","srf","tiff".
;
; OUTPUTS:
;   3D COCOPLOT RGB integer array of dimensions [nx, ny, 3]
;
; RESTRICTIONS:
;   Requires the following procedures and functions:
;     Functions: COCORGB(), COCONORM(),
;     Procedures: COCOSHOW
;
; EXAMPLE:
;   TBD
;
; MODIFICATION HISTORY:
;   Written by:	Malcolm Druett, May 2019
;-

  IF (N_PARAMS() LT 1) THEN BEGIN
    MESSAGE, 'Syntax: Result = COCOPLOT(coco_datacube [, FILTER=filter] '+$
      '[, /RGBTHRESH] [, THRESHMETHOD=threshmethod] [, /QUIET] '+$
      '[, /CURRENT] [, DIMS=dims] [, NAME=name] [, FILEPATH=filepath] '+$
      '[, FILETYPE=filetype])', /INFO
    RETURN, !NULL
  ENDIF

; Check whether handed data or RGB array.
  IF (NOT KEYWORD_SET(filter)) THEN BEGIN
    sz=SIZE(coco_datacube)
    IF ((sz[0] EQ 3) && (sz[3] EQ 3)) THEN BEGIN
      data_int=coco_datacube
    ENDIF ELSE BEGIN
      MESSAGE, "No filter handed to COCOPLOT. Therefore expected 3D RGB cube with third dimension size 3, found respectively "+STRCOMPRESS(STRING(sz[0]),/REMOVE_ALL)+", and "+STRCOMPRESS(STRING(sz[0]),/REMOVE_ALL), /INFO
    ENDELSE
  ; If not handed RGB array, then produce RGB array using COCORGB and COCONORM.
  ENDIF ELSE BEGIN
     data_float=COCORGB(coco_datacube, filter, RGBTHRESH=rgbthresh, THRESHMETHOD=threshmethod)
     data_int=COCONORM(data_float)
  ENDELSE
; Show/save image if requested
  IF NOT KEYWORD_SET(QUIET) THEN $
    COCOSHOW, data_int, CURRENT=current, DIMS=dims, NAME=name, FILEPATH=filepath, FILETYPE=filetype
  RETURN, data_int
END
