;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION COCOPLOT, coco_datacube, filter=filter, rgbthresh=rgbthresh, threshmethod=threshmethod, quiet=quiet, current=current, dims=dims, name=name, filepath=filepath, filetype=filetype
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
;   filter:         Filter of dimensions [nspect_points, 3] specifying
;                   values used to color collpase the datacube.
;   rgbthresh:      Flag to apply saturation thresholding. Defaults to not set.
;   threshmethod:   Scalar string specifying the Saturation thresholding method.
;                   Can be 'fraction', 'numeric' or 'percentile'. Defaults to not set.
;   quiet:          Do not pop-up display image. Defaults to not set.
;   current:        Flag to plot in current window. Defaults to not set.
;   dims:           Image dimensions for display. Defaults to [nx, ny] of
;                   input coco_datacube.
;   name:           String containing output file name, triggers save
;                   of image if present. Does noe require suffix.
;   filepath:       String containting filepath that will be added to name.
;   filetype:       String for output image file type. default = "png". Valid
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
; Check whether handed data or RGB array.
  IF (NOT keyword_set(filter)) THEN BEGIN
    sz=size(coco_datacube)
    IF ((sz[0] EQ 3) && (sz[3] EQ 3)) THEN BEGIN
      data_int=coco_datacube
    ENDIF ELSE BEGIN
      message, "No filter handed to COCOPLOT. Therefore expected 3D RGB cube with third dimension size 3, found respectively "+strcompress(string(sz[0]),/remove_all)+", and "+strcompress(string(sz[0]),/remove_all)
    ENDELSE
  ; If not handed RGB array, then produce RGB array using COCORGB and COCONORM.
  ENDIF ELSE BEGIN
     data_float=COCORGB(coco_datacube, filter, rgbthresh=rgbthresh, threshmethod=threshmethod)
     data_int=COCONORM(data_float)
  ENDELSE
; Show/save image if requested
  cocoshow, data_int, quiet=quiet, current=current, dims=dims, name=name, filepath=filepath, filetype=filetype
  RETURN, data_int
END
