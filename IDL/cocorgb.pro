;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION COCORGB, coco_datacube_in, filter, rgbthresh=rgbthresh, threshmethod=threshmethod
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;   COCORGB
;
; PURPOSE:
;   Collapse a 3D datacube to a single 3D COCOPLOT RGB integer array of dimensions [nx, ny, 3].
;
; CATEGORY:
;   COCOPLOT core
;
; CALLING SEQUENCE:
;   Result = COCORGB(coco_datacube_in, filter)
;
; INPUTS:
;   coco_datacube:  Input data cube of dimensions [nx, ny, nspect_points].
;   filter:         Filter of dimensions [nspect_points, 3].
;
; KEYWORD PARAMETERS:
;   rgbthresh:      Flag to apply saturation thresholding. Defaults to not set.
;   threshmethod:   Scalar string specifying the Saturation thresholding method.
;                   Can be 'fraction', 'numeric' or 'percentile'. Defaults to not set.
;
; OUTPUTS:
;   3D COCOPLOT RGB integer array of dimensions [nx, ny, 3]
;
; RESTRICTIONS:
;   Requires the following procedures and functions:
;     Functions: cgPercentiles()  [coyote IDL library]
;
; EXAMPLE:
;   TBD
;
; MODIFICATION HISTORY:
;   Written by: Malcolm Druett, May 2019
;-
  coco_datacube=coco_datacube_in
  dims=SIZE(coco_datacube)
  ; Thresholding: saturation at max and zero at min values
  IF KEYWORD_SET(rgbthresh) THEN BEGIN
    CASE threshmethod OF
      'fraction': BEGIN
                    datamin=MIN(coco_datacube, /NAN)
                    datamax=MAX(coco_datacube, /NAN)
                    datarange=datamin+rgbthresh*(datamax-datamin)
                  END
      'numeric':  datarange=rgbthresh
      'percentile': datarange=cgPercentiles(coco_datacube, PERCENTILES=rgbthresh)
      ELSE: MESSAGE, "threshmethod not recognised. Should be 'fraction', 'numeric' or 'percentile'.", /INFO
    ENDCASE
    IF (MIN(FINITE(datarange)) EQ 0) THEN MESSAGE, "NAN or INFINTE data detected in requested range.", /INFO
    iw=WHERE(coco_datacube GT datarange[1], count)
    IF (count NE 0) THEN coco_datacube[iw]=datarange[1]
    iw=WHERE(coco_datacube LT datarange[0], count)
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
  coco_data_rgb=DBLARR(dims[1],dims[2],3)
  coco_data_rgb = REFORM($
          REFORM(coco_datacube, dims[1]*dims[2], dims[3]) # filter, $
          dims[1], dims[2], 3)
  RETURN, coco_data_rgb
END
