;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function COCOPLOT, coco_datacube, filter, rgbthresh=rgbthresh, threshmethod=threshmethod
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Takes a 3D datacube and filters for r, g, and b channels
; with third dimension of the datacube equal to filter length
; Returns an RGB array with integer elements from 0, 255
; Linearly scaled 
data_float=COCORGB(coco_datacube, filter, rgbthresh=rgbthresh, threshmethod=threshmethod)
data_int=COCONORM(data_float, rgbthresh=rgbthresh, threshmethod=threshmethod)
return, data_int
end
