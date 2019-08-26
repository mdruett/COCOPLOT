;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION COCORGB, coco_datacube_in, filter, RGBTHRESH=rgbthresh, THRESHMETHOD=threshmethod
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
;   RGBTHRESH:      Saturation thresholding values. Defaults to min-max.
;   THRESHMETHOD:   Scalar string specifying the Saturation thresholding method.
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
;   Written by: Malcolm Druett & Gregal Vissers, May-August 2019
;-

  IF (N_PARAMS() LT 2) THEN BEGIN
    MESSAGE, 'Syntax: Result = COCORGB(coco_datacube_in, filter [, /RGBTHRESH] '+$
      '[, THRESHMETHOD=threshmethod])', /INFO
    RETURN, !NULL
  ENDIF
  coco_datacube=coco_datacube_in
  dims=SIZE(coco_datacube)
  ; Thresholding: saturation at max and zero at min values
  IF (N_ELEMENTS(rgbthresh) GT 0) THEN BEGIN
    datamin = MIN(coco_datacube, /NAN, MAX=datamax)
    CASE threshmethod OF
      'fraction': datarange=datamin+rgbthresh*(datamax-datamin)
      'numeric':  datarange=rgbthresh
      'percentile': datarange=cgPercentiles(coco_datacube, PERCENTILES=rgbthresh)
      ELSE: BEGIN
              MESSAGE, "threshmethod not recognised. Should be 'fraction', 'numeric' or 'percentile'.", /INFO
              datarange = [datamin, datamax]
            END
    ENDCASE
    IF (MIN(FINITE(datarange)) EQ 0) THEN MESSAGE, "NAN or INFINTE data detected in requested range.", /INFO
    iw=WHERE(coco_datacube GT datarange[1], count)
    IF (count NE 0) THEN coco_datacube[iw]=datarange[1]
    iw=WHERE(coco_datacube LT datarange[0], count)
    IF (count NE 0) THEN coco_datacube[iw]=datarange[0]
    coco_datacube=coco_datacube-datarange[0]
  ENDIF
  coco_data_rgb=DBLARR(dims[1],dims[2],3)
  coco_data_rgb = REFORM($
          REFORM(coco_datacube, dims[1]*dims[2], dims[3]) # filter, $
          dims[1], dims[2], 3)
  RETURN, coco_data_rgb
END
