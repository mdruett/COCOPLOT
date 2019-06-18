;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function COCOIMAGE, coco_datacube, filter, rgbthresh=rgbthresh, threshmethod=threshmethod, quiet=quiet, dims=dims, filepath=filepath, name=name
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Takes an rgb integer array 
; displays (unless quiet) and returns and image
; can specify image dimensions as a two element array with keyword dims
  if (n_elements(dims) eq 2) then begin 
     nx=dims[0]
     ny=dims[1]
  endif else begin
     sz=size(coco_datacube)
     nx=sz[1]
     ny=sz[2]
  endelse
  w = WINDOW(DIMENSIONS=[nx,ny], BUFFER=keyword_set(quiet))
  temp_image=image(COCOPLOT(coco_datacube, filter, rgbthresh=rgbthresh, threshmethod=threshmethod), $
    IMAGE_DIMENSIONS=[nx,ny], POSITION=[0.0,0.0,1.0,1.0],/current)
  the_image=temp_image.CopyWindow()
  if (keyword_set(name)) then begin
      fileloc=name
  	if (keyword_set(filepath)) then fileloc=filepath+name
  	write_png, fileloc, the_image
  endif
  return, the_image
end
