;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function COCOFILTPLOT, profile, filter, wavelengths=wavelengths, color=color, xtitle=xtitle, ytitle=ytitle, title=title, dimensions=dimensions, buffer=buffer, current=current, thick=thick
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;	  COCOFILTPLOT
;
; PURPOSE:
;	  Display a plot of the profiles and filters
;
; CATEGORY:
;	  COCOPLOT visualisation
;
; CALLING SEQUENCE:
;	  Result = COCOFILTPLOT()
;
; INPUTS:
;   profile: a 1D line profile, length nl
;   filter:  a set of rgb filters, length nl 
;
; KEYWORD PARAMETERS:
;   wavelengths: a set of wavelength values for the x-axis
;   color:  If .true. the color of the profile will have the RGB hue
;           that the filter would give it, although the brightness may
;           be different depending on the scaling used. 
;           Otherwise profile is black.
;   xlabel: text on xlabel.
;   ylabel: text on ylabel.
;   title:  title of plot. Not present by default 
;   specify the dimensions of the image generated
;
; OUTPUTS:
;	  Display a plot with input profile and filters overplotted.
;
; RESTRICTIONS:
;   Requires the following procedures and functions:
;     Functions: COCOFILTNORM()
;
; EXAMPLE:
;   profile = 1-20*COCOFILTNORM(findgen(101)-50,0,10)
;   filter = COCOFILTER(FINDGEN(101)-50, filtertype='normal')
;   plot = COCOFILTPLOT(profile, filter)
;
; MODIFICATION HISTORY:
;   Based on a function in COCOpy by A.G.M Pietrow
; 	Written by:	Malcolm Druet, May 2019
;-
   profile = double(profile)
   filter = double(filter)
   if (not keyword_set(wavelengths)) then wavelengths=indgen(n_elements(profile))
   ; setting colour of plot
   ; factor 0.8 to ensure line does not come out white!
   if (not keyword_set(color)) then begin
      rgb_value = profile # filter
	  rgb_int = reform(round(0.8*rgb_value*255/max(rgb_value)))
   endif else begin
      rgb_int=!null
   endelse
   if (not keyword_set(thick)) then thick=2
   normprofile=profile/max(profile)
   normfilter=filter/max(filter)
   convprof=filter
   convprof[*,0]=normprofile * reform(normfilter[*,0])
   convprof[*,1]=normprofile * reform(normfilter[*,1])
   convprof[*,2]=normprofile * reform(normfilter[*,2])

    myplot=plot(wavelengths,normprofile, xtitle=xtitle, ytitle=ytitle, title=title, thick=thick, color=rgb_int, sym='o', sym_filled=1, buffer=buffer)
    myplot.xstyle = 1
    for i=0,2 do begin
      myplot=plot(wavelengths,reform(normfilter[*,i]), xtitle=xtitle, $
        ytitle=ytitle, title=title, thick=thick, color=shift([255,0,0],i), sym='o', $
        sym_filled=1, linestyle='--', /current, /overplot)
      myplot=plot(wavelengths,reform(convprof[*,i]), xtitle=xtitle, $
        ytitle=ytitle, title=title, thick=thick, color=shift([255,0,0],i), sym='o', $
        sym_filled=1, linestyle='-', /current, /overplot)
    endfor

    return, myplot
end
