;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function COCONORM, coco_data_rgb_in, rgbthresh=rgbthresh, threshmethod=threshmethod
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;	  COCONORM
;
; PURPOSE:
;   Apply saturation threshold to COCOPLOT RGB image
;	  
; CATEGORY:
;	  COCOPLOT core
;
; CALLING SEQUENCE:
;   Result = COCONORM(data)
;
; INPUTS:
;	  coco_data_rgb_in: Input RGB image of dimensions [nx, ny, 3]
;	
; KEYWORD PARAMETERS:
;	  rgbthresh:      Flag to apply saturation thresholding. Defaults to not set.
;   threshmethod:   Scalar string specifying the Saturation thresholding method.
;                   Can be 'fraction', 'numeric' or 'percentile'. Defaults to not set.
;
; OUTPUTS:
;	  RGB byte-array with integer elements, linearly scaled between 0 and 255.
;
; RESTRICTIONS:
;   Requires the following procedures and functions:
;     Functions: cgPercentiles()  [coyote IDL library]
;
; EXAMPLE:
;   TBD
;
; MODIFICATION HISTORY:
; 	Written by:	Malcolm Druett, May 2019
;-
  coco_data_rgb=coco_data_rgb_in
  if keyword_set(rgbthresh) then begin
     if (threshmethod eq 'fraction') then begin
        datarange=cgPercentiles(coco_data_rgb, PERCENTILES=rgbthresh)
  	  maxval=datarange[1]-datarange[0]
     endif else begin
        maxval=rgbthresh[1]-rgbthresh[0] 
     endelse
  endif else begin
     maxval=max(coco_data_rgb, /NAN)
  endelse
  return, round(255D*coco_data_rgb/maxval)
end
