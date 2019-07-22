;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function COCOFILTER, Array, FILTERTYPE=filtertype, R=r, G=g, B=b
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
;   Result = COCOFILTER(Array)
;
; INPUTS:
;	  Array:  1D-array (integer, float or byte) with wavelength or time values
;
; KEYWORD PARAMETERS:
;	  FILTERTYPE:	  Scalar string specifying the type of filter. One of three
;                 values is accepted:
;                 'single'  : single points.
;                             Uses keywords R, G and B, specifying the
;                             indices in Array to use for each filter.
;                 'band'    : bands of points.
;                             Uses keyword R, G and B, specifying with 2-element
;                             arrays the lower and upper indices in Array for
;                             each filter.
;                 'normal'  : normal distribution filters, like the cones of the eye
;                             Uses keyword R, G and B, specifying with 2-element
;                             arrays the means (first element) and standard
;                             deviation (second element) of the normal 
;                             distribution functions used in the rgb filters.
;                 Defaults to 'normal'.
;	  R:  Scalar or 2-element array specifying the position, band boundaries or
;       mean and standard deviation of the red filter. Defaults to: 
;       - first, middle and last index in Array, in case of FILTERTYPE='band'
;       - lower and upper indices bounding the first, middle and last third of
;         the Array range, in case of FILTERTYPE='band'
;       - means at the first, mid-point and last value in Array, and 1.96
;         standard deviation, in case of FILTERTYPE='normal'
;	  G:  Scalar or 2-element array specifying the position, band boundaries or
;       mean and standard deviation of the green filter. Defaults as for R.
;	  B:  Scalar or 2-element array specifying the position, band boundaries or
;       mean and standard deviation of the blue filter. Defaults as for R.
;
; OUTPUTS:
;	  Filter (2-dimensional array of dimensions [nArray, 3]) for
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
  nArray=n_elements(Array)    
  if (nArray ne 1) then begin
     array_filt=Array
  endif else begin
     array_filt=indgen(Array)
	   nArray=Array
  endelse
  if (n_elements(filtertype) ne 1) then filtertype = 'normal'  
  case filtertype of
    'single': begin
                filter=make_array(nArray,3,/double,value=0)
                if (n_elements(r) eq 1) then filter[r,0]=1D else filter[nArray-1,0] =1D
                if (n_elements(g) eq 1) then filter[g,1]=1D else filter[round((nArray-1)/2),1] =1D
                if (n_elements(b) eq 1) then filter[b,2]=1D else filter[0,2] =1D
	            end
    'band':   begin
                filter=make_array(nArray,3,/double,value=0)
                filt_bits=make_array(3,2,/double)
	              nl=double(nArray-1)
                if (n_elements(r) eq 2) then filt_bits[0,*]=r else filt_bits[0,*]=[ceil((2D*(nl))/3D),nArray-1]
                if (n_elements(g) eq 2) then filt_bits[1,*]=g else filt_bits[1,*]=[ceil((nl)/3D),floor((2D*(nl))/3D)]
                if (n_elements(b) eq 2) then filt_bits[2,*]=b else filt_bits[2,*]=[0,floor((nl)/3D)]
                filt_int=1D/double(filt_bits[*,1]-filt_bits[*,0]+1)   
	              for i_filt=0,2 do begin
                   for i_filt2=filt_bits[i_filt,0],filt_bits[i_filt,1] do filter[i_filt2,i_filt]=filt_int[i_filt]
                endfor
	            end
    'normal': begin
                ; normal distribution "eyelike" filters"
                array_filt = double(array_filt) 
                if (n_elements(b) eq 2) then begin   
	               prof_sigma=double(b[1])
	               prof_mean=double(b[0])
                endif else begin
                   prof_sigma=(array_filt[nArray-1]-array_filt[0])/(2.0D*1.96D)
                   prof_mean=array_filt[0]
	              endelse
                filter_b=COCOFILTNORM(array_filt, prof_mean, prof_sigma)
                if (n_elements(g) eq 2) then begin
	               prof_sigma=double(g[1])
	               prof_mean=double(g[0])
                endif else begin
                   prof_mean=(array_filt[nArray-1]+array_filt[0])/2.0D
                   prof_sigma=(array_filt[nArray-1]-array_filt[0])/(2.0D*1.96D)
                endelse
                filter_g=COCOFILTNORM(array_filt, prof_mean, prof_sigma)
                if (n_elements(r) eq 2) then begin 
	               prof_sigma=double(r[1])
	               prof_mean=double(r[0])
                endif else begin
                   prof_mean=array_filt[nArray-1]
                   prof_sigma=(array_filt[nArray-1]-array_filt[0])/(2.0D*1.96D)
                endelse
                filter_r=COCOFILTNORM(array_filt, prof_mean, prof_sigma)  
                filter=[[filter_r], [filter_g], [filter_b]]
	            end
  endcase
  return, filter
end
