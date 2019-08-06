;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION COCOFILTPLOT, profile, filter, spect_points=spect_points, color=color, xtitle=xtitle, ytitle=ytitle, title=title, dimensions=dimensions, buffer=buffer, current=current, thick=thick, font_size=font_size, normfactor=normfactor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;   COCOFILTPLOT
;
; PURPOSE:
;   Display a plot of the profiles and filters.
;
; CATEGORY:
;   COCOPLOT visualisation
;
; CALLING SEQUENCE:
;   Result = COCOFILTPLOT()
;
; INPUTS:
;   profile: A 1D line profile, length nl.
;   filter:  A set of rgb filters, length nl.
;
; KEYWORD PARAMETERS:
;   spect_points: A set of spectral data point values for the x-axis.
;   color:  If .true. the color of the profile will have the RGB hue
;           that the filter would give it, although the brightness may
;           be different depending on the scaling used.
;           Otherwise profile is black.
;   xlabel: Text on xlabel.
;   ylabel: Text on ylabel.
;   title:  Title of plot. Not present by default.
;   dimensions: Specify the dimensions of the image generated.
;               No default set.
;   buffer: Places the image in a display buffer, rather than
;           displaying it on-screen.
;   current: Places the image in the most recently opened graphics window.
;   thick: Integer sepecifying the thicknesses of the lines used
;   font_size: Integer specifying the font size used. No default set.
;   normfactor: Real number from 0 to 1 that may be used to separate
;               the heights of the normalised plots of the filters and
;               the line profiles. Defaults to 1.0.
;
; OUTPUTS:
;   Display a plot with input profile and filters overplotted.
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
;   Written by:	Malcolm Druet, May 2019
;-
   profile = DOUBLE(profile)
   filter = DOUBLE(filter)
   IF (NOT KEYWORD_SET(spect_points)) THEN spect_points=INDGEN(N_ELEMENTS(profile))
   IF (NOT KEYWORD_SET(normfactor)) THEN normfactor=1.0
   ; setting colour of plot
   ; factor 0.8 to ensure line does not come out white!
   IF (NOT KEYWORD_SET(color)) THEN BEGIN
      rgb_value = profile # filter
      rgb_int = REFORM(ROUND(0.8*rgb_value*255/MAX(rgb_value)))
   ENDIF ELSE BEGIN
      rgb_int=!null
   ENDELSE
   IF (NOT KEYWORD_SET(thick)) THEN thick=2
   normprofile=normfactor*profile/MAX(profile)
   normfilter=filter/MAX(filter)
   convprof=filter
   convprof[*,0]=normprofile * REFORM(normfilter[*,0])
   convprof[*,1]=normprofile * REFORM(normfilter[*,1])
   convprof[*,2]=normprofile * REFORM(normfilter[*,2])

    myplot=PLOT(spect_points,normprofile, XTITLE=xtitle, YTITLE=ytitle, TITLE=title, THICK=thick, COLOR=rgb_int, SYM='o', SYM_FILLED=1, BUFFER=buffer, FONT_SIZE=font_size)
    myplot.xstyle = 1
    FOR i=0,2 DO BEGIN
      myplot=PLOT(spect_points,REFORM(normfilter[*,i]), XTITLE=xtitle, $
        YTITLE=ytitle, TITLE=title, THICK=thick, COLOR=SHIFT([255,0,0],i), sym='o', $
        SYM_FILLED=1, LINESTYLE='--', /CURRENT, /OVERPLOT)
      myplot=PLOT(spect_points,REFORM(convprof[*,i]), xtitle=xtitle, $
        YTITLE=ytitle, TITLE=title, THICK=thick, COLOR=SHIFT([255,0,0],i), sym='o', $
        SYM_FILLED=1, LINESTYLE='-', /CURRENT, /OVERPLOT)
    ENDFOR

    RETURN, myplot
END
