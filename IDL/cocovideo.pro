;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO COCOVIDEO, coco_datacube, filter, fps, name, filepath=filepath, startstop=startstop, rgbthresh=rgbthresh, threshmethod=threshmethod, loud=loud, dims=dims
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;   COCOVIDEO
;
; PURPOSE:
;   Generate and save an animation of COCOPLOT images.
;
; CATEGORY:
;   COCOPLOT visualisation
;
; CALLING SEQUENCE:
;   COCOVIDEO, coco_datacube, filter, fps, name
;
; INPUTS:
;   coco_datacube:  Input 4D data cube of dimensions [nx, ny, nspect_points, nt].
;   filter:         Filter of dimensions [nspect_points, 3].
;   fps:            Frames per second.
;   name:           String containing output file name.
;
; KEYWORD PARAMETERS:
;   filepath:       Output filepath prefixed to the "name" variable.
;   startstop:      Start and stop indices for time dimension. Defaults to
;                   [0,nt-1].
;   rgbthresh:      Flag to apply saturation thresholding. Defaults to not set.
;   threshmethod:   Scalar string specifying the Saturation thresholding method.
;                   Can be 'fraction', 'numeric' or 'percentile'. Defaults to not set.
;   loud:           Display the video. Defaults to not set.
;   dims:           Image dimensions for display. Defaults to [nx, ny] of
;                   input coco_datacube.
;
; OUTPUTS:
;   Save a series of COCOPLOT images as an animation.
;
; RESTRICTIONS:
;   Requires the following procedures and functions:
;     Functions:  IDLFFVIDEOWRITE(), COCOPLOT(), COCOIMAGE(), COCOSHOW()
;
; EXAMPLE:
;   TBD
;
; MODIFICATION HISTORY:
;   Written by: Malcolm Druett, May 2019
;-
  sz = SIZE(coco_datacube)
  nx = sz[1]
  ny = sz[2]
  nt = sz[4]
  IF (N_ELEMENTS(dims) EQ 2) THEN BEGIN 
     nx=dims[0]
     ny=dims[1]
  ENDIF 
  IF KEYWORD_SET(startstop) THEN startstop=startstop ELSE startstop=[0,nt-1]
  fileloc=name
  IF (KEYWORD_SET(filepath)) THEN fileloc=filepath+name
  video_object_name = idlffvideowrite(fileloc)
  video_stream_name =video_object_name.addvideostream(nx, ny, fps)
  ; Create video while showing images if loud keyword set
  IF KEYWORD_SET(loud) THEN w=WINDOW(DIMENSIONS=[nx,ny]) ELSE w=WINDOW(DIMENSIONS=[nx,ny],/BUFFER)
  FOR i_loop=startstop[0],startstop[1] DO BEGIN
        my_rgb=COCOPLOT(coco_datacube[*,*,*,i_loop], filter, RGBTHRESH=rgbthresh, THRESHMETHOD=threshmethod, CURRENT=1, DIMS=[nx, ny])
        my_image=w.copywindow()
        timestamp = video_object_name.put(video_stream_name, my_image)
  ENDFOR
  OBJ_DESTROY, video_object_name
END
