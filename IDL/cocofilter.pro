;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function COCOFILTER, wavelengths, FILTERTYPE=filtertype, R=r, G=g, B=b
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;	  COCOFILTER
;
; PURPOSE:
;	  Generate COCOPLOT filters
;
; CATEGORY:
;   COCOPLOT core
;
; CALLING SEQUENCE:
;   Result = COCOFILTER(wavelengths)
;
; INPUTS:
;	  Wavelengths:  1D-array (integer, float or byte) with wavelength or time values
;
; KEYWORD PARAMETERS:
;	  FILTERTYPE:	  Scalar string specifying the type of filter. One of three
;                 values is accepted:
;                 'single'  : single points.
;                             Uses keywords R, G and B, specifying the
;                             indices in Wavelengths to use for each filter.
;                 'band'    : bands of points.
;                             Uses keyword R, G and B, specifying with 2-element
;                             arrays the lower and upper indices in Wavelengths for
;                             each filter.
;                 'normal'  : normal distribution filters, like the cones of the eye
;                             Uses keyword R, G and B, specifying with 2-element
;                             arrays the means (first element) and standard
;                             deviation (second element) of the normal 
;                             distribution functions used in the rgb filters.
;                 Defaults to 'normal'.
;	  R:  Scalar or 2-element array specifying the position, band boundaries or
;       mean and standard deviation of the red filter. Defaults to: 
;       - first, middle and last index in Wavelengths, in case of FILTERTYPE='band'
;       - lower and upper indices bounding the first, middle and last third of
;         the Wavelengths range, in case of FILTERTYPE='band'
;       - means at the first, mid-point and last value in Wavelengths, and 1.96
;         standard deviation, in case of FILTERTYPE='normal'
;	  G:  Scalar or 2-element array specifying the position, band boundaries or
;       mean and standard deviation of the green filter. Defaults as for R.
;	  B:  Scalar or 2-element array specifying the position, band boundaries or
;       mean and standard deviation of the blue filter. Defaults as for R.
;
; OUTPUTS:
;	  Filter (2-dimensional array of dimensions [nWavelengths, 3]) for
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
; 	Written by:	Malcolm Druett, May 2019
;-
   nlambda=n_elements(wavelengths)    
   if (nlambda ne 1) then begin
      wavelengths_filt=wavelengths
   endif else begin
      wavelengths_filt=indgen(wavelengths)
	  nlambda=wavelengths
   endelse
   if (n_elements(filtertype) ne 1) then filtertype = 'normal'  
   case filtertype of
   'single': begin
      filter=make_array(nlambda,3,/double,value=0)
      if (n_elements(r) eq 1) then filter[r,0]=1D else filter[nlambda-1,0] =1D
      if (n_elements(g) eq 1) then filter[g,1]=1D else filter[round((nlambda-1)/2),1] =1D
      if (n_elements(b) eq 1) then filter[b,2]=1D else filter[0,2] =1D
	  end
   'band': begin
      filter=make_array(nlambda,3,/double,value=0)
      filt_bits=make_array(3,2,/double)
	  nl=double(nlambda-1)
      if (n_elements(r) eq 2) then filt_bits[0,*]=r else filt_bits[0,*]=[0,floor((nl)/3D)]
      if (n_elements(g) eq 2) then filt_bits[1,*]=g else filt_bits[1,*]=[ceil((nl)/3D),floor((2D*(nl))/3D)]
      if (n_elements(b) eq 2) then filt_bits[2,*]=b else filt_bits[2,*]=[ceil((2D*(nl))/3D),nlambda-1]
      filt_int=1D/double(filt_bits[*,1]-filt_bits[*,0]+1)   
	  for i_filt=0,2 do begin
         for i_filt2=filt_bits[i_filt,0],filt_bits[i_filt,1] do filter[i_filt2,i_filt]=filt_int[i_filt]
      endfor
	  end
   'normal': begin
     ; normal distribution "eyelike" filters"
     wavelengths_filt = double(wavelengths_filt) 
     if (n_elements(b) eq 2) then begin   
	    prof_sigma=double(b[1])
	    prof_mean=double(b[0])
     endif else begin
        prof_sigma=(wavelengths_filt[nlambda-1]-wavelengths_filt[0])/(2.0D*1.96D)
        prof_mean=wavelengths_filt[0]
	 endelse
     filter_b=COCOFILTNORM(wavelengths_filt, prof_mean, prof_sigma)
     if (n_elements(g) eq 2) then begin
	    prof_sigma=double(g[1])
	    prof_mean=double(g[0])
     endif else begin
        prof_mean=(wavelengths_filt[nlambda-1]+wavelengths_filt[0])/2.0D
        prof_sigma=(wavelengths_filt[nlambda-1]-wavelengths_filt[0])/(2.0D*1.96D)
	 endelse
     filter_g=COCOFILTNORM(wavelengths_filt, prof_mean, prof_sigma)
     if (n_elements(r) eq 2) then begin 
	    prof_sigma=double(r[1])
	    prof_mean=double(r[0])
     endif else begin
        prof_mean=wavelengths_filt[nlambda-1]
        prof_sigma=(wavelengths_filt[nlambda-1]-wavelengths_filt[0])/(2.0D*1.96D)
	 endelse
     filter_r=COCOFILTNORM(wavelengths_filt, prof_mean, prof_sigma)  
     filter=[[filter_r], [filter_g], [filter_b]]
	 end
   endcase
return, filter
end
