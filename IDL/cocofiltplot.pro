;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function COCOFILTPLOT, profile, filter, wavelengths=wavelengths, color=color, xtitle=xtitle, ytitle=ytitle, title=title, dimensions=dimensions, buffer=buffer, current=current, thick=thick, font_size=font_size, normfactor=normfactor
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
;   wavelengths: A set of wavelength values for the x-axis
;   color:  If .true. the color of the profile will have the RGB hue
;           that the filter would give it, although the brightness may
;           be different depending on the scaling used. 
;           Otherwise profile is black.
;   xlabel: Text on xlabel.
;   ylabel: Text on ylabel.
;   title:  Title of plot. Not present by default 
;   dimensions: Specify the dimensions of the image generated.
;               No default set
;   buffer: Places the image in a display buffer, rather than
;           displaying it on-screen
;   current: Places the image in the most recently opened graphics window.
;   thick: Integer sepecifying the thicknesses of the lines used
;   font_size: Integer specifying the font size used. No default set.
;   normfactor: real number from 0 to 1 that may be used to separate
;               the heights of the normalised plots of the filters and
;               the line profiles. Defaults to 1.0.
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
   if (not keyword_set(normfactor)) then normfactor=1.0
   ; setting colour of plot
   ; factor 0.8 to ensure line does not come out white!
   if (not keyword_set(color)) then begin
      rgb_value = profile # filter
	  rgb_int = reform(round(0.8*rgb_value*255/max(rgb_value)))
   endif else begin
      rgb_int=!null
   endelse
   if (not keyword_set(thick)) then thick=2
   normprofile=normfactor*profile/max(profile)
   normfilter=filter/max(filter)
   convprof=filter
   convprof[*,0]=normprofile * reform(normfilter[*,0])
   convprof[*,1]=normprofile * reform(normfilter[*,1])
   convprof[*,2]=normprofile * reform(normfilter[*,2])

    myplot=plot(wavelengths,normprofile, xtitle=xtitle, ytitle=ytitle, title=title, thick=thick, color=rgb_int, sym='o', sym_filled=1, buffer=buffer, font_size=font_size)
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
