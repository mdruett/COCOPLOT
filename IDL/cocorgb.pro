;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION COCORGB, coco_datacube_in, filter, rgbthresh=rgbthresh, threshmethod=threshmethod
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;	  COCORGB
;
; PURPOSE:
;	  Collapse a 3D datacube to a single 3D COCOPLOT RGB integer array of dimensions [nx, ny, 3].
;
; CATEGORY:
;	  COCOPLOT core
;
; CALLING SEQUENCE:
; 
;	  Result = COCORGB(coco_datacube_in, filter) 
;
; INPUTS:
;	  coco_datacube:  Input data cube of dimensions [nx, ny, nspect_points].
;         filter:         Filter of dimensions [nspect_points, 3]. 
;
; KEYWORD PARAMETERS:
;	  rgbthresh:      Flag to apply saturation thresholding. Defaults to not set.
;         threshmethod:   Scalar string specifying the Saturation thresholding method.
;                         Can be 'fraction', 'numeric' or 'percentile'. Defaults to not set.
;
; OUTPUTS:
;	  3D COCOPLOT RGB integer array of dimensions [nx, ny, 3]
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
coco_datacube=coco_datacube_in
dims=size(coco_datacube)
; Thresholding: saturation at max and zero at min values
IF keyword_set(rgbthresh) THEN BEGIN
   CASE threshmethod OF
   'fraction': BEGIN
      datamin=min(coco_datacube, /NAN)
      datamax=max(coco_datacube, /NAN)
      datarange=datamin+rgbthresh*(datamax-datamin)
      END
   'numeric': datarange=rgbthresh
   'percentile': datarange=cgPercentiles(coco_datacube, PERCENTILES=rgbthresh)
   ELSE: message, "threshmethod not recognised. Should be 'fraction', 'numeric' or 'percentile'.", /info
   ENDCASE
   IF (min(finite(datarange)) EQ 0) THEN message, "NAN or INFINTE data detected in requested range.", /info
   iw=where(coco_datacube GT datarange[1], count)
   IF (count NE 0) THEN coco_datacube[iw]=datarange[1]
   iw=where(coco_datacube LT datarange[0], count)
   IF (count NE 0) THEN coco_datacube[iw]=datarange[0]
   coco_datacube=coco_datacube-datarange[0]
ENDIF
; convolve datacube with filters by slice
; if you can do the whole cube at once, then change this
; MD: done below, commented out out version for meantime
; removed first overwrite in  reform, seemss to destroy datacube
;for x=0,(dims[1]-1) do begin 
;   slice=double(reform(coco_datacube[x,*,0:dims[3]-1]))
;   coco_data_rgb[x,*,0:2] = slice # double(filter)
;endfor
coco_data_rgb=dblarr(dims[1],dims[2],3)
coco_data_rgb = reform($
        reform(coco_datacube, dims[1]*dims[2], dims[3]) # filter, $
        dims[1], dims[2], 3)
RETURN, coco_data_rgb
END
