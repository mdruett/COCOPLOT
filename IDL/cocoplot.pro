;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function COCOPLOT, coco_datacube, filter, rgbthresh=rgbthresh, threshmethod=threshmethod, rgb_in=rgb_in, quiet=quiet, current=current, dims=dims, name=name, filepath=filepath, filetype=filetype
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;	  COCOPLOT
;
; PURPOSE:
;	  Apply filter to 3D datacube and return COCOPLOT RGB integer array
;
; CATEGORY:
;	  COCOPLOT core
;
; CALLING SEQUENCE:
; 
;	Result = COCOPLOT(coco_datacube, filter)
;
; INPUTS:
;   coco_datacube:  Input data cube of dimensions [nx, ny, nspect_points]
;   filter:         Filter of dimensions [nspect_points, 3] 
;
; KEYWORD PARAMETERS:
;   rgbthresh:      Flag to apply saturation thresholding. Defaults to not set.
;   threshmethod:   Scalar string specifying the Saturation thresholding method.
;                   Can be 'fraction', 'numeric' or 'percentile'. Defaults to not set.
;   rgb_in:         Include if you are handing an already color collapsed RGB
;                   array of dinemsions [nx,ny,3] to the function.
;   quiet:          Do not pop-up display image. Defaults to not set.
;   current:        Flag to plot in current window. Defaults to not set.
;   dims:           Image dimensions for display. Defaults to [nx, ny] of
;                   input coco_datacube.
;   name:           String containing Ooutput file name, triggers save
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
; 	Written by:	Malcolm Druett, May 2019
;-
; Check whether handed data or RGB array
  if (keyword_set(rgb_in)) then begin
     sz=size(coco_datacube)
     if ((sz[0] EQ 3) && (sz[3] EQ 3)) then begin
        data_int=coco_datacube
     endif else begin
        message, "RGB_IN keyword set: expected 3D cube with third dimension size 3, found respectively "+strcompress(string(sz[0]),/remove_all)+", and "+strcompress(string(sz[0]),/remove_all)
     endelse
; If not handed RGB array, then produce RGB array using COCORGB and COCONORM
   endif else begin
     data_float=COCORGB(coco_datacube, filter, rgbthresh=rgbthresh, threshmethod=threshmethod)
     data_int=COCONORM(data_float, rgbthresh=rgbthresh, threshmethod=threshmethod)
  endelse
; Show/save image if requested
  cocoshow, data_int, quiet=quiet, current=current, dims=dims, name=name, filepath=filepath, filetype=filetype
  return, data_int
end
