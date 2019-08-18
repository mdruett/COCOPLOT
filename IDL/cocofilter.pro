;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION COCOFILTER, Array, FILTERTYPE=filtertype, R=r, G=g, B=b
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;   COCOFILTER
;
; PURPOSE:
;   Generate COCOPLOT filters.
;
; CATEGORY:
;   COCOPLOT core
;
; CALLING SEQUENCE:
;   Result = COCOFILTER(Array)
;
; INPUTS:
;   Array:  1D-array (integer, float or byte) with spectral or time values.
;
; KEYWORD PARAMETERS:
;	  FILTERTYPE:	  Scalar string specifying the type of filter. One of three
;                 values is accepted:
;                 'single'  : Single points.
;                             Uses keywords R, G and B, specifying the
;                             indices in Array to use for each filter.
;                 'band'    : Bands of points.
;                             Uses keyword R, G and B, specifying with 2-element
;                             arrays the lower and upper indices in Array for
;                             each filter.
;                 'normal'  : Normal distribution filters, like the cones of the eye
;                             Uses keyword R, G and B, specifying with 2-element
;                             arrays the means (first element) and standard
;                             deviation (second element) of the normal 
;                             distribution functions used in the rgb filters.
;                 Defaults to 'normal'.
;   R:  Scalar or 2-element array specifying the position, band boundaries or
;       mean and standard deviation of the red filter. Defaults to: 
;       - first, middle and last index in Array, in case of FILTERTYPE='band'.
;       - lower and upper indices bounding the first, middle and last third of
;         the Array range, in case of FILTERTYPE='band'.
;       - means at the first, mid-point and last value in Array, and 1.96
;         standard deviation, in case of FILTERTYPE='normal'.
;   G:  Scalar or 2-element array specifying the position, band boundaries or
;       mean and standard deviation of the green filter. Defaults as for R.
;   B:  Scalar or 2-element array specifying the position, band boundaries or
;       mean and standard deviation of the blue filter. Defaults as for R.
;
; OUTPUTS:
;   Filter (2-dimensional array of dimensions [nArray, 3]) for
;   multiplication with the data cube.
;
; RESTRICTIONS:
;   Requires the following procedures and functions:
;     Functions: COCOFILTNORM()
;
; EXAMPLE:
;   filter = COCOFILTER(FINDGEN(101)-50, filtertype='band')
;
; MODIFICATION HISTORY:
;   Written by: Malcolm Druett & Gregal Vissers, May-August 2019
;-
  
  IF (N_PARAMS() LT 1) THEN BEGIN
    MESSAGE, 'Syntax: Result = COCOFILTER(Array [, FILTERTYPE=filtertype] '+$
      '[, R=r] [, G=g] [, B=b])', /INFO
    RETURN, !NULL
  ENDIF

  ; Process inputs
  nArray=N_ELEMENTS(array)
  IF (nArray GT 1) THEN $
    array_filt=Array $
  ELSE BEGIN
    array_filt=INDGEN(Array)
    nArray=N_ELEMENTS(array_filt)
  ENDELSE
  IF (N_ELEMENTS(filtertype) NE 1) THEN filtertype = 'normal'

  ; Get filter defaults and create filters
  default = COCOFILTER_DEFAULTS(Array, FILTERTYPE=filtertype)
  filter = DBLARR(nArray,3)   ; Output filter definition, overridden for 'normal'

  CASE filtertype OF
    'single': BEGIN
                IF (N_ELEMENTS(r) LT 1) THEN r = default.r
                IF (N_ELEMENTS(g) LT 1) THEN g = default.g
                IF (N_ELEMENTS(b) LT 1) THEN b = default.b
                filter[r,0] = 1D  & filter[g,1] = 1D  & filter[b,2] = 1D

              END
    'band':   BEGIN
                filt_bits = DBLARR(3,2)
                IF (N_ELEMENTS(r) NE 2) THEN r = default.r
                IF (N_ELEMENTS(g) NE 2) THEN g = default.g
                IF (N_ELEMENTS(b) NE 2) THEN b = default.b
                filt_bits[0,*] = r  & filt_bits[1,*] = g  & filt_bits[2,*] = b 

                filt_int=1D/DOUBLE(filt_bits[*,1]-filt_bits[*,0]+1)
                FOR i_filt=0,2 DO BEGIN
                  FOR i_filt2=filt_bits[i_filt,0],filt_bits[i_filt,1] DO filter[i_filt2,i_filt]=filt_int[i_filt]
                ENDFOR
              END
    'normal': BEGIN
                ; normal distribution "eyelike" filters"
                IF (N_ELEMENTS(r) NE 2) THEN r = default.r
                IF (N_ELEMENTS(g) NE 2) THEN g = default.g
                IF (N_ELEMENTS(b) NE 2) THEN b = default.b
                filter = [ [COCOFILTNORM(array_filt, r[0], r[1])], $
                           [COCOFILTNORM(array_filt, g[0], g[1])], $
                           [COCOFILTNORM(array_filt, b[0], b[1])] ]

              END
  ENDCASE
  RETURN, filter
END
