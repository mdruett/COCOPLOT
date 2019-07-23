;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function COCOPLOT, coco_datacube, filter, rgbthresh=rgbthresh, threshmethod=threshmethod
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
;	  coco_datacube:  Input data cube of dimensions [nx, ny, nspect_points]
;   filter:         Filter of dimensions [nspect_points, 3] 
;
; KEYWORD PARAMETERS:
;	  rgbthresh:      Flag to apply saturation thresholding. Defaults to not set.
;   threshmethod:   Scalar string specifying the Saturation thresholding method.
;                   Can be 'fraction', 'numeric' or 'percentile'. Defaults to not set.
;   Note: keyword settings are passed on to COCORGB() and COCONORM(), and do not
;   have an effect inside COCOPLOT.
;
; OUTPUTS:
;   3D COCOPLOT RGB integer array of dimensions [nx, ny, 3]
;
; RESTRICTIONS:
;   Requires the following procedures and functions:
;     Functions: COCORGB(), COCONORM()
;
; EXAMPLE:
;   TBD
;
; MODIFICATION HISTORY:
; 	Written by:	Malcolm Druett, May 2019
;-
  data_float=COCORGB(coco_datacube, filter, rgbthresh=rgbthresh, threshmethod=threshmethod)
  data_int=COCONORM(data_float, rgbthresh=rgbthresh, threshmethod=threshmethod)
  return, data_int
end
