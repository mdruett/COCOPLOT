;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION COCOFILTER_DEFAULTS, Array, FILTERTYPE=filtertype
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;   COCOFILTER_DEFAULTS
;
; PURPOSE:
;   Return COCOPLOT filters defaults.
;
; CATEGORY:
;   COCOPLOT core
;
; CALLING SEQUENCE:
;   Result = COCOFILTER_DEFAULTS(Array)
;
; INPUTS:
;   Array:  1D-array (integer, float or byte) with spectral or time values.
;
; KEYWORD PARAMETERS:
;	  FILTERTYPE:	  Scalar string specifying the type of filter. One of three
;                 values is accepted:
;                 'single'  : Single points.
;                             If set, return structure contains the
;                             indices in Array to use for each filter.
;                 'band'    : Bands of points.
;                             If set, return structure contains 2-element
;                             arrays with the lower and upper indices in Array for
;                             each filter.
;                 'normal'  : Normal distribution filters, like the cones of the eye
;                             If set, return structure contains 2-element
;                             arrays with the means (first element) and standard
;                             deviation (second element) of the normal 
;                             distribution functions used in the rgb filters.
;                 Defaults to 'normal'.
;
; OUTPUTS:
;   Structure with filter default values for R, G and B to be used by
;   COCOFILTER().
;
; EXAMPLE:
;   defaults = COCOFILTER_DEFAULTS(FINDGEN(101)-50, filtertype='band')
;   HELP, defaults, /STRUCT
;
; MODIFICATION HISTORY:
;   Written by: Malcolm Druett & Gregal Vissers, August 2019
;-

  IF (N_PARAMS() LT 1) THEN BEGIN
    MESSAGE, 'Syntax: Result = COCOFILTER_DEFAULTS(Array '+$
      '[, FILTERTYPE=filtertype])', /INFO
    RETURN, !NULL
  ENDIF

  ; Process inputs
  nArray = N_ELEMENTS(Array)
  IF (N_ELEMENTS(filtertype) NE 1) THEN filtertype = 'normal'

  ; Get defaults
  CASE filtertype OF
    'single': BEGIN
                r = nArray-1
                g = ROUND((nArray-1)/2.)
                b = 0
              END
    'band':   BEGIN
                r = [CEIL((2D*(nArray-1))/3D),nArray-1]
                g = [CEIL((nArray-1)/3D),FLOOR((2D*(nArray-1))/3D)]
                b = [0,FLOOR((nArray-1)/3D)]
              END
    'normal': BEGIN
                stdev = (Array[nArray-1]-Array[0])/(2.D*1.96D)
                b = [Array[0], stdev]
                g = [(Array[nArray-1]+Array[0])/2.0D, stdev]
                r = [Array[nArray-1], stdev]
              END
    ELSE:     BEGIN
                MESSAGE, "ERROR: Filtertype not recognized. Must be one "+$
                  "of 'single', 'band' or 'normal'.", /INFO
                RETURN, !NULL
              END
  ENDCASE

  RETURN, {r:r, g:g, b:b}

END
