;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO COCOVIDEO, coco_datacube, filter, filepath, fps, startstop=startstop, rgbthresh=rgbthresh, threshmethod=threshmethod, loud=loud, dims=dims
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;	  COCOVIDEO
;
; PURPOSE:
;	  Generate and save an animation of COCOPLOT images
;
; CATEGORY:
;	  COCOPLOT visualisation
;
; CALLING SEQUENCE:
;	  Result = COCOVIDEO(coco_data_rgb_int)
;
; INPUTS:
;	  coco_datacube:  Input 4D data cube of dimensions [nx, ny, nWavelengths, nt]
;   filter:         Filter of dimensions [nWavelengths, 3] 
;   filepath:       Output path and filename.
;   fps:            Frames per second
;
; KEYWORD PARAMETERS:
;   startstop:    Start and stop indices for time dimension. Defaults to
;                 [0,nt-1]
;	  rgbthresh:    Flag to apply saturation thresholding. Defaults to not set.
;   threshmethod: Scalar string specifying the Saturation thresholding method.
;                 Can be 'fraction', 'numeric' or 'percentile'. Defaults to not set.
;   loud:         Display the video. Defaults to not set.
;   dims:         image dimensions for display. Defaults to [nx, ny] of
;                 input coco_datacube.
;
; OUTPUTS:
;	  Save a series of COCOPLOT images as an animation.
;
; RESTRICTIONS:
;   Requires the following procedures and functions:
;     Functions:  IDLFFVIDEOWRITE(), COCOPLOT(), COCOIMAGE(), COCOSHOW()
;
; EXAMPLE:
;   TBD
;
; MODIFICATION HISTORY:
; 	Written by:	Malcolm Druett, May 2019
;-
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
