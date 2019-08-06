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
;   Written by:	Malcolm Druett, May 2019
;-
  nArray=N_ELEMENTS(array)
  IF (nArray NE 1) THEN BEGIN
    array_filt=Array
  ENDIF ELSE BEGIN
    array_filt=INDGEN(Array)
    nArray=Array
  ENDELSE
  IF (N_ELEMENTS(filtertype) NE 1) THEN filtertype = 'normal'
  CASE filtertype OF
    'single': BEGIN
                filter=MAKE_ARRAY(nArray,3,/DOUBLE,VALUE=0)
                IF (N_ELEMENTS(r) EQ 1) THEN filter[r,0]=1D ELSE filter[nArray-1,0] =1D
                IF (N_ELEMENTS(g) EQ 1) THEN filter[g,1]=1D ELSE filter[ROUND((nArray-1)/2),1] =1D
                IF (N_ELEMENTS(b) EQ 1) THEN filter[b,2]=1D ELSE filter[0,2] =1D
              END
    'band':   BEGIN
                filter=MAKE_ARRAY(nArray,3,/DOUBLE,VALUE=0)
                filt_bits=MAKE_ARRAY(3,2,/DOUBLE)
                nl=DOUBLE(nArray-1)
                IF (N_ELEMENTS(r) EQ 2) THEN filt_bits[0,*]=r ELSE filt_bits[0,*]=[CEIL((2D*(nl))/3D),nArray-1]
                IF (N_ELEMENTS(g) EQ 2) THEN filt_bits[1,*]=g ELSE filt_bits[1,*]=[CEIL((nl)/3D),FLOOR((2D*(nl))/3D)]
                IF (N_ELEMENTS(b) EQ 2) THEN filt_bits[2,*]=b ELSE filt_bits[2,*]=[0,FLOOR((nl)/3D)]
                filt_int=1D/double(filt_bits[*,1]-filt_bits[*,0]+1)
                FOR i_filt=0,2 DO BEGIN
                  FOR i_filt2=filt_bits[i_filt,0],filt_bits[i_filt,1] DO filter[i_filt2,i_filt]=filt_int[i_filt]
                ENDFOR
              END
    'normal': BEGIN
                ; normal distribution "eyelike" filters"
                array_filt = DOUBLE(array_filt)
                IF (N_ELEMENTS(b) EQ 2) THEN BEGIN
                  prof_sigma=DOUBLE(b[1])
                  prof_mean=DOUBLE(b[0])
                ENDIF ELSE BEGIN
                  prof_sigma=(array_filt[nArray-1]-array_filt[0])/(2.0D*1.96D)
                  prof_mean=array_filt[0]
                ENDELSE
                filter_b=COCOFILTNORM(array_filt, prof_mean, prof_sigma)
                IF (N_ELEMENTS(g) EQ 2) THEN BEGIN
                  prof_sigma=DOUBLE(g[1])
                  prof_mean=DOUBLE(g[0])
                ENDIF ELSE BEGIN
                  prof_mean=(array_filt[nArray-1]+array_filt[0])/2.0D
                  prof_sigma=(array_filt[nArray-1]-array_filt[0])/(2.0D*1.96D)
                ENDELSE
                filter_g=COCOFILTNORM(array_filt, prof_mean, prof_sigma)
                IF (N_ELEMENTS(r) EQ 2) THEN BEGIN 
                  prof_sigma=DOUBLE(r[1])
                  prof_mean=DOUBLE(r[0])
                ENDIF ELSE BEGIN
                  prof_mean=array_filt[nArray-1]
                  prof_sigma=(array_filt[nArray-1]-array_filt[0])/(2.0D*1.96D)
                ENDELSE
                filter_r=COCOFILTNORM(array_filt, prof_mean, prof_sigma)
                filter=[[filter_r], [filter_g], [filter_b]]
              END
  ENDCASE
  RETURN, filter
END
