;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION COCOFILTNORM, spect_points, prof_mean, prof_sigma
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;   COCOFILTNORM
;
; PURPOSE:
;   Generate normal distribution style filters.
;
; CATEGORY:
;	  COCOPLOT core
;
; CALLING SEQUENCE:
;	  Result = COCOFILTNORM(spect_points, prof_mean, prof_sigma)
;
; INPUTS:
;   spect_points: 1D-array of spectral data points.
;   prof_mean:    Mean of the normal distribution. 
;   prof_sigma:   Standard devaition of the normal distribution.
;
; OUTPUTS:
;	  Normal distribution style filter (1-dimensional array of length
;         nWavelengths). 
;
; EXAMPLE:
;   filter = COCOFILTNORM(FINDGEN(101)-50, 20., 10.)
;
; MODIFICATION HISTORY:
;   Written by:	Malcolm Druett, May 2019
;-
  nlambda=N_ELEMENTS(spect_points)
  unifprof=MAKE_ARRAY(nlambda,/DOUBLE,VALUE=1)
  filter_temp=EXP(-(DOUBLE(spect_points)-prof_mean)^2/(2D*prof_sigma^2))
  filt_max=TRANSPOSE(unifprof) # filter_temp
  filt_norm=1D/filt_max[0]
  filter_temp=filt_norm*filter_temp
  RETURN, filter_temp
END
