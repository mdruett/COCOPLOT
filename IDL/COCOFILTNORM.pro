;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function COCOFILTNORM, wavelengths, prof_mean, prof_sigma
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;	  COCOFILTNORM
;
; PURPOSE:
;   Generate normal distribution style filters
;
; CATEGORY:
;	  COCOPLOT core
;
; CALLING SEQUENCE:
;	  Result = COCOFILTNORM(wavelengths, prof_mean, prof_sigma)
;
; INPUTS:
;	  wavelengths:  1D-array of wavelengths.
;   prof_mean:    Mean of the normal distribution. 
;   prof_sigma:   Standard devaition of the normal distribution.
;
; OUTPUTS:
;	  Normal distribution style filter (1-dimensional array of length
;   nWavelengths). 
;
; EXAMPLE:
;   filter = COCOFILTNORM(FINDGEN(101)-50, 20., 10.)
;
; MODIFICATION HISTORY:
; 	Written by:	Malcolm Druett, May 2019
;-
  nlambda=n_elements(wavelengths)
  unifprof=make_array(nlambda,/double,value=1)
  filter_temp=exp(-(double(wavelengths)-prof_mean)^2/(2D*prof_sigma^2))
  filt_max=transpose(unifprof) # filter_temp
  filt_norm=1D/filt_max[0]
  filter_temp=filt_norm*filter_temp
  return, filter_temp
end
