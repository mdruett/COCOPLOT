;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function COCONORM, coco_data_rgb_in, rgbthresh=rgbthresh, threshmethod=threshmethod
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Takes a 3D datacube with the third dimension of size 3
; Returns an RGB array with integer elements from 0, 255
; Linearly scaled 
coco_data_rgb=coco_data_rgb_in
if keyword_set(rgbthresh) then begin
   if (threshmethod eq 'fraction') then begin
      datarange=cgPercentiles(coco_data_rgb, PERCENTILES=rgbthresh)
	  maxval=datarange[1]-datarange[0]
   endif else begin
      maxval=rgbthresh[1]-rgbthresh[0] 
   endelse
endif else begin
   maxval=max(coco_data_rgb, /NAN)
endelse
return, round(255D*coco_data_rgb/maxval)
end
