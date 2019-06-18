;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function COCOSHOW, coco_data_rgb_int, quiet=quiet, current=current, dims=dims, filepath=filepath, name=name
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Takes an rgb integer array 
; displays (unless quiet) and returns and image
; can specify image dimensions as a two element array with keyword dims
  if (n_elements(dims) eq 2) then begin   
     nx=dims[0]
     ny=dims[1]
  endif else begin
     sz=size(coco_data_rgb_int)
     nx=sz[1]
     ny=sz[2]
  endelse
  if keyword_set(quiet) then begin
     w=WINDOW(DIMENSIONS=[nx,ny],/BUFFER) 
  endif else begin
     if (not keyword_set(current)) then begin
        w=WINDOW(DIMENSIONS=[nx,ny])
     endif
  endelse
  temp_image=image(coco_data_rgb_int, IMAGE_DIMENSIONS=[nx,ny], POSITION=[0.0,0.0,1.0,1.0],/current)
  the_image=temp_image.CopyWindow()
  if (keyword_set(name)) then begin
      fileloc=name
  	if (keyword_set(filepath)) then fileloc=filepath+name
  	write_png, fileloc, the_image
  endif
  return, the_image
end
