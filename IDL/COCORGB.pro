;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function COCORGB, coco_datacube_in, filter, rgbthresh=rgbthresh, threshmethod=threshmethod
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Takes a datacube and three filters
; Collapses the datacube to an [nx, ny, 3] RGB-style array of floats
coco_datacube=coco_datacube_in
dims=size(coco_datacube)
; Thresholding: saturation at max and zero at min values
if keyword_set(rgbthresh) then begin
   case threshmethod of
   'fraction': begin
      datamin=min(coco_datacube, /NAN)
      datamax=max(coco_datacube, /NAN)
	  datarange=datamin+rgbthresh*(datamax-datamin)
	  end
   'numeric': datarange=rgbthresh
   'percentile': datarange=cgPercentiles(coco_datacube, PERCENTILES=rgbthresh)
   else: print, "threshmethod not recognised. Should be 'fraction', 'numeric' or 'percentile'."
   endcase
   if (min(finite(datarange)) eq 0) then print, "NAN or INFINTE data detected in requested range."
   iw=where(coco_datacube gt datarange[1], count)
   if (count ne 0) then coco_datacube[iw]=datarange[1]
   iw=where(coco_datacube lt datarange[0], count)
   if (count ne 0) then coco_datacube[iw]=datarange[0]
   coco_datacube=coco_datacube-datarange[0]
endif
; convolve datacube with filters by slice
; if you can do the whole cube at once, then change this
; MD: done below, commented out out version for meantime
; removed first overwrite in  reform, seemss to destroy datacube
;for x=0,(dims[1]-1) do begin 
;   slice=double(reform(coco_datacube[x,*,0:dims[3]-1]))
;   coco_data_rgb[x,*,0:2] = slice # double(filter)
;endfor
coco_data_rgb=dblarr(dims[1],dims[2],3)
coco_data_rgb = reform($
        reform(coco_datacube, dims[1]*dims[2], dims[3]) # filter, $
        dims[1], dims[2], 3)
return, coco_data_rgb
end
