;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO COCOVIDEO, coco_datacube, filter, filepath, fps, startstop=startstop, rgbthresh=rgbthresh, threshmethod=threshmethod, loud=loud, dims=dims
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; takes a 4D coco_datacube: (x, y, lambda, t)
; 3 RGB filters over the lambda values
; a filepath inc filename and ending
; frames per second (FPS)
; keyword start and stop indices for time dimension
; generates a CoCo video
sz = size(coco_datacube)
nx = sz[1]
ny = sz[2]
nt = sz[4]
if (n_elements(dims) eq 2) then begin 
   nx=dims[0]
   ny=dims[1]
endif 
IF KEYWORD_SET(startstop) THEN startstop=startstop ELSE startstop=[0,nt-1]
video_object_name = idlffvideowrite(filepath)
video_stream_name =video_object_name.addvideostream(nx, ny, fps)
IF KEYWORD_SET(loud) THEN BEGIN
   w=WINDOW(DIMENSIONS=[nx,ny])
   FOR i_loop=startstop[0],startstop[1] DO BEGIN
      my_image=COCOSHOW(COCOPLOT(coco_datacube[*,*,*,i_loop], filter, rgbthresh=rgbthresh, threshmethod=threshmethod), $
        current=1, dims=[nx, ny])
      timestamp = video_object_name.put(video_stream_name, my_image)
   ENDFOR
ENDIF ELSE BEGIN
   FOR i_loop=startstop[0],startstop[1] DO BEGIN
  	  my_image=COCOIMAGE(coco_datacube[*,*,*,i_loop], filter, rgbthresh=rgbthresh, threshmethod=threshmethod, quiet=1) 
      timestamp = video_object_name.put(video_stream_name, my_image)
   ENDFOR
ENDELSE

obj_destroy, video_object_name
END
