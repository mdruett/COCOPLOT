;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION COCONORM, coco_data_rgb
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
;	  coco_data_rgb: Input RGB float array of dimensions [nx, ny, 3]
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

;  Remove any stray negative values
   iw=where(coco_data_rgb LT 0, count)
   IF (count NE 0) THEN coco_data_rgb[iw]=0.0
;  Linear normalisation
   maxval=max(coco_data_rgb, /NAN)
   RETURN, round(255D*coco_data_rgb/maxval)
END
